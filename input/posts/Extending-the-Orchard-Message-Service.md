---
Title: Extending the Orchard Message Service
Published: 2016-08-25 19:22:55
Tags:
- Open Source
- Orchard
RedirectFrom: 2016/08/25/Extending-the-Orchard-Message-Service/index.html
---

This journey begin in a somewhat normal way. I needed to allow a user in our Orchard instance to submit a form that would send an email to our ticketing system. I know, no API exists for the ticketing system and I had to use an old school way. After getting the initial implementation, we discovered that the email that was being sent was HTML and that HTML was supported, but a bug fix required emails to be in plain text.  Not only that, but the information that gets parsed has to be the first content in the email. I was hit by a double whammy, my email was HTML and the template that was getting applied to the email was our theme template. So couple different items came out of this.

* Templates in your theme override templates in your module.
* The Message Service uses the EmailMessageChannel.
* The EmailMessageChannel uses a specific template.
* The EmailMessageChannel detects if the message contains HTML and sets it on the MailMessage.

These are good items to know, time to dig into the source code and determine what I needed to do to use my template or send an email as plain text. After a little digging around, I determined that I needed to create two classes, two interfaces, and two templates in my module. The first item I needed to create was an implementation of *IMessageChannel* for my new type of message channel.

```

using Orchard.Messaging.Services;

namespace Orchard.MyCustomModule.Services {
    public interface IPlainTextMessageChannel : IMessageChannel {
    }
}

```

With that created I need to create a concrete example of the message channel. I just copied the *EmailMessageChannel* found in the *Orchard.Email* module. I renamed the class *PlainTextMessageChannel* and implemented the interface. I then changed the message type to be *PlainText*, changed the default template to be *Template_PlainText_Wrapper*. Finally I set the *IsBodyHtml* to false as I wanted it to be plain text, not HTML.

```

namespace Orchard.MyCustomModule.Services {
    public class PlainTextMessageChannel : Component, IPlainTextMessageChannel, IDisposable {
        private readonly SmtpSettingsPart _smtpSettings;
        private readonly IShapeFactory _shapeFactory;
        private readonly IShapeDisplay _shapeDisplay;
        private readonly Lazy<SmtpClient> _smtpClientField;
        public static readonly string MessageType = "PlainText";
    
        public PlainTextMessageChannel(
            IOrchardServices orchardServices,
            IShapeFactory shapeFactory,
            IShapeDisplay shapeDisplay) {
            _shapeFactory = shapeFactory;
            _shapeDisplay = shapeDisplay;
            _smtpSettings = orchardServices.WorkContext.CurrentSite.As<SmtpSettingsPart>();
            _smtpClientField = new Lazy<SmtpClient>(CreateSmtpClient);
        }
         
        public void Dispose() {
            if (!_smtpClientField.IsValueCreated) {
                return;
            }
             
            _smtpClientField.Value.Dispose();
        }
              
        public void Process(IDictionary<string, object> parameters) {
            
            if (!_smtpSettings.IsValid()) {
                return;
            }
               
            var emailMessage = new EmailMessage {
                Body = Read(parameters, "Body"),
                Subject = Read(parameters, "Subject"),
                Recipients = Read(parameters, "Recipients"),
                ReplyTo = Read(parameters, "ReplyTo"),
                From = Read(parameters, "From"),
                Bcc = Read(parameters, "Bcc"),
                Cc = Read(parameters, "CC")
            };
                    
            if (emailMessage.Recipients.Length == 0) {
                Logger.Error("Plain text email message doesn't have any recipient");
                return;
            }
                 
            // Apply default Body alteration for PlainText Channel.
            var template = _shapeFactory.Create("Template_PlainText_Wrapper", Arguments.From(new {
                Content = new MvcHtmlString(emailMessage.Body)
            }));
    
            var mailMessage = new MailMessage {
                Subject = emailMessage.Subject,
                Body = _shapeDisplay.Display(template),
                IsBodyHtml = false
            };
    
            if (parameters.ContainsKey("Message")) {
                // A full message object is provided by the sender.
    
                var oldMessage = mailMessage;
                mailMessage = (MailMessage)parameters["Message"];
    
                if (String.IsNullOrWhiteSpace(mailMessage.Subject))
                    mailMessage.Subject = oldMessage.Subject;
    
                if (String.IsNullOrWhiteSpace(mailMessage.Body)) {
                    mailMessage.Body = oldMessage.Body;
                    mailMessage.IsBodyHtml = oldMessage.IsBodyHtml;
                }
            }
    
            try {
                foreach (var recipient in ParseRecipients(emailMessage.Recipients)) {
                    mailMessage.To.Add(new MailAddress(recipient));
                }
                if (!String.IsNullOrWhiteSpace(emailMessage.Cc)) {
                    foreach (var recipient in ParseRecipients(emailMessage.Cc)) {
                        mailMessage.CC.Add(new MailAddress(recipient));
                    }
                }
                if (!String.IsNullOrWhiteSpace(emailMessage.Bcc)) {
                    foreach (var recipient in ParseRecipients(emailMessage.Bcc)) {
                        mailMessage.Bcc.Add(new MailAddress(recipient));
                    }
                }
                if (!String.IsNullOrWhiteSpace(emailMessage.From)) {
                    mailMessage.From = new MailAddress(emailMessage.From);
                }
                else {
                    // Take 'From' address from site settings or web.config.
                    mailMessage.From = !String.IsNullOrWhiteSpace(_smtpSettings.Address)
                        ? new MailAddress(_smtpSettings.Address)
                        : new MailAddress(((SmtpSection)ConfigurationManager.GetSection("system.net/mailSettings/smtp")).From);
                }
                if (!String.IsNullOrWhiteSpace(emailMessage.ReplyTo)) {
                    foreach (var recipient in ParseRecipients(emailMessage.ReplyTo)) {
                        mailMessage.ReplyToList.Add(new MailAddress(recipient));
                    }
                }
                _smtpClientField.Value.Send(mailMessage);
            }
            catch (Exception e) {
                Logger.Error(e, "Could not send plain text email");
            }
        }
    
        private SmtpClient CreateSmtpClient() {
            // If no properties are set in the dashboard, use the web.config value.
            if (String.IsNullOrWhiteSpace(_smtpSettings.Host)) {
                return new SmtpClient(); 
            }
            var smtpClient = new SmtpClient {
                UseDefaultCredentials = _smtpSettings.RequireCredentials && _smtpSettings.UseDefaultCredentials
            };
            if (!smtpClient.UseDefaultCredentials && !String.IsNullOrWhiteSpace(_smtpSettings.UserName)) {
                smtpClient.Credentials = new NetworkCredential(_smtpSettings.UserName, _smtpSettings.Password);
            }
            if (_smtpSettings.Host != null) {
                smtpClient.Host = _smtpSettings.Host;
            }
            smtpClient.Port = _smtpSettings.Port;
            smtpClient.EnableSsl = _smtpSettings.EnableSsl;
            smtpClient.DeliveryMethod = SmtpDeliveryMethod.Network;
            return smtpClient;
        }
    
        private string Read(IDictionary<string, object> dictionary, string key) {
            return dictionary.ContainsKey(key) ? dictionary[key] as string : null;
        }
    
        private IEnumerable<string> ParseRecipients(string recipients) {
            return recipients.Split(new[] {',', ';'}, StringSplitOptions.RemoveEmptyEntries);
        }
    }
}

```

Now the last piece that needs to be done is implementing the channel selector that gets used by Orchard messaging to know which template to use. Again, I made sure to make the channel name *PlainText* and the only other item that I needed to changed was the messageType check and the priority level.


```

using Orchard;
using Orchard.Messaging.Services;

namespace Orchard.MyCustomModule.Services {
    public class DefaultPlainTextMessageChannelSelector : Component, IMessageChannelSelector {
        private readonly IWorkContextAccessor _workContextAccessor;
        public const string ChannelName = "PlainText";

        public DefaultPlainTextMessageChannelSelector(IWorkContextAccessor workContextAccessor) {
            _workContextAccessor = workContextAccessor;
        }

        public MessageChannelSelectorResult GetChannel(string messageType, object payload) {
            if (messageType == "PlainText") {
                var workContext = _workContextAccessor.GetContext();
                return new MessageChannelSelectorResult {
                    Priority = 49,
                    MessageChannel = () => workContext.Resolve<IPlainTextMessageChannel>()
                };
            }

            return null;
        }
    }
}

```

Now all that is left is creating the default template that you need in the *Views* folder to match the name of the template that you set in the *PlainTextMessageChannel*. To use the new message channel just pass *PlainText* as the message type and Orchard will wire up everything else.

```

_messageService.Send("PlainText", parameters);

```