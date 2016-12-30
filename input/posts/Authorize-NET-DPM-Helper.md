---
Title: Authorize .NET DPM Helper
Published: 2015-02-26 19:00:00
Tags:
- ASP .NET MVC
- Authorize .NET
RedirectFrom: blog/html/2015/02/26/authorize_net_dpm_helper.html
---

I recently started diving into learning about payment gateways and payment processing. This is a new area for me and there a lot to learn. After Authorize .NET was settled on as our payment gateway, I went about the task of learning their .NET SDK. There are way to many options and I do not understand the pros and cons of each method, but after reading their documentation I settled on using their Direct Post Method (DPM) as it limited our exposure to sensitive information and the featureset is perfect for what we are currently doing.

However, their example is a little rudimentary and just writes the HTML for the form using string concatenation and would be hard to maintain and customize. So I was curious as to what it would take to create an HTML helper for ASP .NET MVC that would be similiar to Html.BeginForm, so that way I could build by form using razor while still using their open and end form methods.

\*I decided to try gists compared to the default highlighting in Tinkerer.

Here is their [example](https://developer.authorize.net/integration/fifteenminutes/csharp/) before:

```
public ActionResult DPM()
{
     String ApiLogin = "Your_login_id";
     String TxnKey = "Your_transaction_key";

     String checkoutform = DPMFormGenerator.OpenForm(ApiLogin, TxnKey, 2.25M,
                                                  "https://YOUR_RELAY_RESPONSE_URL", true);

     // Add a credit card number input field
     checkoutform = checkoutform + @"<p><div style='float:left;width:250px;'><label>Credit Card
        Number</label><div id = 'CreditCardNumber'><input type='text' size='28' name='x_card_num'
        value='4111111111111111' id='x_card_num'/></div></div>";

     // Add an expiry date input field
     checkoutform = checkoutform + @"<div style='float:left;width:70px;'><label>Exp.</label>
        <div id='CreditCardExpiration'><input type='text' size='5' maxlength='5' name='x_exp_date'
        value='0116' id='x_exp_date'/></div></div>";

     // Add a CVV input field
     checkoutform = checkoutform + @"<div style='float:left;width:70px;'><label>CCV</label>
          <div id='CCV'><input type='text' size='5' maxlength='5' name='x_card_code' id='x_card_code'
          value='123' /></div></div></p>";

     // Add a Submit button
     checkoutform = checkoutform + "<div style='clear:both'></div>";
     checkoutform = checkoutform + @"<p><input type='submit' class='submit' value='Order with
          DPM!' /></p>";

     checkoutform = checkoutform + DPMFormGenerator.EndForm();
     return Content("<html>" + checkoutform + "</html>");
}
```

After lots of googling and a couple of really helpful StackOverflow posts, I was able to determine that I needed to create a class that implemented IDisposable and make that class responsible for opening the form and ending the form. After that all that was needed was to create the helper extension.

```
public static class FormExtensions
 {
    private class DirectPostForm : IDisposable
    {
        private readonly HtmlHelper _helper;

        public DirectPostForm(HtmlHelper helper, string apiLogin, string transactionKey, decimal amount,
            string returnUrl, bool isTest)
        {
            _helper = helper;
            _helper.ViewContext.Writer.Write(DPMFormGenerator.OpenForm(apiLogin, transactionKey, amount, returnUrl,
                isTest));
        }

        public void Dispose()
        {
            _helper.ViewContext.Writer.Write(DPMFormGenerator.EndForm());
        }
    }

    public static IDisposable BeginDirectPostForm(this HtmlHelper helper, string apiLogin, string transactionKey,
        decimal amount,
        string returnUrl, bool isTest)
    {
        return new DirectPostForm(helper, apiLogin, transactionKey, amount, returnUrl, isTest);
    }
}
```

Now with the HTML Helper, your form can be created like this:

```
@using (Html.BeginDirectPostForm("ApiLogin", "TransactionKey", 2.25M, "https://YOUR_RELAY_RESPONSE_URL", true))
{
    <p>
        <div style='float: left; width: 250px;'>
            <label> Credit Card Number </label>
            <div id='CreditCardNumber'>
                <input type='text' size='28' name='x_card_num'
                       value='4111111111111111' id='x_card_num' />
            </div>
        </div>
        <div style='float: left; width: 70px;'>
            <label>Exp.</label>
            <div id='CreditCardExpiration'>
                <input type='text' size='5' maxlength='5' name='x_exp_date'
                       value='0116' id='x_exp_date' />
            </div>
        </div>
        <div style='float: left; width: 70px;'>
            <label>CCV</label>
            <div id='CCV'>
                <input type='text' size='5' maxlength='5' name='x_card_code' id='x_card_code'
                       value='123' />
            </div>
        </div>
    </p>
    <div style='clear: both'></div>
    <p>
        <input type='submit' class='submit' value='Order with DPM!' />
    </p>
}
```

This is much cleaner and easier to create a custom form. This code is up on Github under the project [authorize-net-helpers](https://github.com/phillipsj/authorize-net-helpers). I am planning to get a package up on Nuget this weekend, of which I have no clue how to really do.

Thanks,

Jamie