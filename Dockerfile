FROM mcr.microsoft.com/dotnet/core/sdk:2.2-bionic

WORKDIR /code/app

RUN dotnet tool install -g Wyam.Tool

ENTRYPOINT ~/.dotnet/tools/wyam --recipe Blog --theme CleanBlog --preview --watch