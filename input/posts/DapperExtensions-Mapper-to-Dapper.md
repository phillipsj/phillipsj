---
Title: DapperExtensions Mapper to Dapper
Published: 2015-02-19 19:00:00
Tags:
- .NET
- Dapper
- ORM
RedirectFrom: blog/html/2015/02/19/dapperextensions_mapper_to_dapper.html
---

I have used several of the differnet Object Relation Mappers (ORMs) out there and I find myself going back to [Dapper](https://github.com/StackExchange/dapper-dot-net). Dapper provides all the functionality that I find that I need and gives the the full power of the best DSL for working with a database, SQL. It is fast and lightweight. However, I do not know many peeps that want to waste there time writing the typical CRUD operations. Projects like [DapperExtensions](https://github.com/tmsmith/Dapper-Extensions), Dapper.Contrib, Dapper.Rainbow, and others, give users plenty of choices.

I like using DapperExtensions because I like class mappings to map my POCOs to tables since most legacy databases typically do not follow C# naming conventions. The other libraries use attributes, which is fine, but not an approach I typically like. The big issue that arises is DapperExtensions use the ClassMapper to generate SQL statements aliasing the columns. This works until you need to fallback to just plain Dapper. So to solve this issue and still use the mapping files, I created a custom ClassMapper and implemented the ITypeMap interface so that way I could use my mapping file to set the type map on the Dapper SqlMapper.

First step is to create a class that implements IMemberMap from Dapper.

```
public class CustomClassMapper<T>: ClassMapper<T>,
                                    SqlMapper.ITypeMap where T : class
{
    public ConstructorInfo FindConstructor(string[] names, Type[] types)
    {
        return this.EntityType.GetConstructor(Type.EmptyTypes);
    }

    public ConstructorInfo FindExplicitConstructor()
    {
       return null;
    }

    public SqlMapper.IMemberMap GetConstructorParameter(
                        ConstructorInfo constructor, string columnName)
    {
        return null;
    }

    public SqlMapper.IMemberMap GetMember(string columnName)
    {
        if (Properties.SingleOrDefault(x =>
                        x.ColumnName == columnName) != null)
        {
            return new CustomMemberMap(
                        this.EntityType.GetMember(Properties.First(x =>
                            x.ColumnName == columnName).Name).Single(),
                        columnName);
        }
        else
        {
            return null;
        }
    }
}
```

Now that you have a member map in place, now it is type to create your custom
DapperExtensions ClassMapper.

```
public class CustomMemberMap : SqlMapper.IMemberMap
{
    private readonly MemberInfo _member;
    private readonly string _columnName;

    public CustomMemberMap(MemberInfo member, string columnName)
    {
        this._member = member;
        this._columnName = columnName;
    }

    public string ColumnName
    {
        get { return _columnName; }
    }

    public FieldInfo Field
    {
        get { return _member as FieldInfo; }
    }

    public Type MemberType
    {
        get
        {
            switch (_member.MemberType)
            {
                case MemberTypes.Field:
                    return ((FieldInfo)_member).FieldType;
                case MemberTypes.Property:
                    return ((PropertyInfo)_member).PropertyType;
                default:
                    throw new NotSupportedException();
            }
        }
    }

    public ParameterInfo Parameter
    {
        get { return null; }
    }

    public PropertyInfo Property
    {
        get { return _member as PropertyInfo; }
    }
}
```

Now that you have both a CustomClassMapper that also implements ITypeMap from Dapper you can now input the following code write before you execute a Dapper method when you need to fall back from DapperExtensions to Dapper.

```
// Note that Person is a POCO and PersonMap is your mapping file
SqlMapper.SetTypeMap(typeof(Person), new PersonMap());
```

I hope others find this useful when needing to use Dapper with DapperExtensions.