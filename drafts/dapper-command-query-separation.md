---
Title: "Dapper Command-Query Separation"
Published: 11/09/2017 08:38:13
Tags: 
- .NET
- Dapper
- ORM
- CQRS
---
# Dapper Command-Query Separation

I am still a big fan of [Dapper]() and use it for most of my .NET projects that require database access. Over the years I have discovered that the repsoitory pattern seldomly meets my needs. Database queries and commands can get quite long and it makes it hard to find and reason about all that is happening in the repository class. After reading a blog post by Jimmy Bogard titled [CQRS Post](), I picked up this pattern for using Dapper.

## Example Query

Here is the interface for the query.

```
using System.Data;

public interface IQuery<T> {
    T Execute(IDbConnection connection);
}
```

Here is an implementation of the how you use the query.

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

```
using System.Data

public interface ICommand {
    void Execute(IDbConnection conncetion);
}
```

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

```
public void Update(PetUpdateViewModel pet){
    IDbConnection connection = new SqlConnection("");
    return new UpdatePet(pet).Execute(connection);
}
```