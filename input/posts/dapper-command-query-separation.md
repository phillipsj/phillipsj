---
Title: "Dapper Command-Query Separation"
Published: 11/11/2017 09:02:50
Tags: 
- .NET
- Dapper
- ORM
- CQRS
---
# Dapper Command-Query Separation

I am still a big fan of [Dapper](https://github.com/StackExchange/Dapper) and use it for most of my .NET projects that require database access. Over the years I have discovered that the repository pattern seldom meets my needs. Database queries and commands can get quite long and it makes it hard to find and reason about all that is happening in the repository class. After reading a blog post by Jimmy Bogard from several years ago, I picked up this pattern and started using it with Dapper.

## Example Query

Here is the interface for the query.

```
using System.Data;

public interface IQuery<T> {
    T Execute(IDbConnection connection);
}
```

Here is an implementation of the how you use the interface.

```
using System.Data;
using System.Linq;
using Dapper;

public class GetPet : IQuery<PetDetailViewModel> {
    private readonly int _id;

    public GetPet(int id) {
        _id = id;
    }

    public PetDetailViewModel Execute(IDbConnection connection) {
        return connection.Query<Pet>(@"SELECT PETID as Id, NAME as Name FROM PET WHERE PETID = @id;", new { id = _id })
            .FirstOrDefault();
    }
}
```

Now this is how you would use it.

```
public PetDetailViewModel GetPetDetail(int id){
    IDbConnection connection = new SqlConnection("");
    return new GetPet(id).Execute(connection);
}
```

## Example Command

Here is the interface for the command.

```
using System.Data

public interface ICommand {
    void Execute(IDbConnection conncetion);
}
```

Here is an implementation of the how you use the interface. 

```
using System.Data;
using System.Linq;
using Dapper;

public class UpdatePet : ICommand {
    private readonly PetUpdateViewModel _pet;

    public UpdatePet(PetUpdateViewModel pet) {
        _pet = pet;
    }

    public void Execute(IDbConnection connection) {
        connection.Execute("UPDATE PETS WHERE PETID = @id SET NAME = @name;" { id = pet.Id, name = pet.Name });
    }
}
```

Now this is how you would use it.

```
public void Update(PetUpdateViewModel pet){
    IDbConnection connection = new SqlConnection("");
    return new UpdatePet(pet).Execute(connection);
}
```

## Conclusion

This is a very simple implementation and works for the types of apps I am typically creating. It isn't a one size fits all approach and we still use other techniques along with ORMs to get the job done. 
