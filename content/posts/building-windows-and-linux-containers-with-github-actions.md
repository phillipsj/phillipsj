---
title: "Building Windows and Linux Containers with GitHub Actions"
date: 2021-12-22T21:09:42-05:00
tags:
- Open Source
- PowerShell
- PowerShell Containers
- Microsoft And Linux
- Containers
- Docker
- GitHub Actions
- DevOps
---

I have been discussing [PowerShell modules in containers](https://www.phillipsj.net/posts/how-to-install-modules-in-a-windows-powershell-core-container/) and building [multiplatform](https://www.phillipsj.net/posts/creating-a-multiplatform-powershell-core-app-container/) containers in my last few posts. I want to follow up those posts with the [GitHub Actions](https://github.com/features/actions) that I created for the [pstools](https://github.com/phillipsj/pstools) repository. I created two GH Actions, one called `CI` for PRs and commits and one called `Publish` that runs when a GitHub release is created. These actions leverage the matrix and strategy to configure agents for building Linux, Windows 2019, and Windows 2022 container images. The publish workflow differs just a little because it also pushes and generates a manifest.

## CI Workflow

This workflow is only executed on pushed to main and any pull requests to main. The whole purpose is to ensure that the container images are built properly. The piece to focus on is the `strategy` section as it creates the build matrix for each OS, which is required when building Windows containers. Then based on OS, I set some OS specific settigns like which `base` to use and which Dockerfile. Then it is matter of executing the build with the different parameters configured.

```YAML
name: CI Workflow
on:
  push:
    branches:
    - main
  pull_request:
    branches:
    - main

jobs:
  build-containers:
    name: Build Containers
    runs-on: ${{ matrix.os }}
    strategy:
      max-parallel: 3
      matrix:
        os: [ubuntu-latest, windows-2019, windows-2022]
        include:
        - os: ubuntu-latest
          base: alpine-3.14
          file: Dockerfile.linux
        - os: windows-2019
          base: nanoserver-1809
          file: Dockerfile.windows
        - os: windows-2022
          base: nanoserver-ltsc2022
          file: Dockerfile.windows
    steps:
    - name: Checkout
      uses: actions/checkout@v2
    - name: Docker Build
      run: |
        docker build -f ${{ matrix.file }} --build-arg BASE=${{ matrix.base }} .
```  

## Publish Workflow

The biggest difference between this one and the CI workflow is the trigger being set as release with a type of published. You will see almost the same matrix as before with a tag parameter added based on OS. This ensures that the tag for the release is used along with using the standardized tagging for those images. Then along with building the containers, they are pushed to DockerHub along with having a manifest generated.

```YAML
name: Publish Workflow
on:
  release:
    types:
    - published

jobs:
  build-publish-containers:
    name: Build and Publish Containers
    runs-on: ${{ matrix.os }}
    strategy:
      max-parallel: 3
      matrix:
        os: [ubuntu-latest, windows-2019, windows-2022]
        include:
        - os: ubuntu-latest
          base: alpine-3.14
          file: Dockerfile.linux
          tag: phillipsj/pstools:${{ github.event.release.tag_name }}-linux-amd64
        - os: windows-2019
          base: nanoserver-1809
          file: Dockerfile.windows
          tag: phillipsj/pstools:${{ github.event.release.tag_name }}-windows-ltsc2019-amd64
        - os: windows-2022
          base: nanoserver-ltsc2022
          file: Dockerfile.windows
          tag: phillipsj/pstools:${{ github.event.release.tag_name }}-windows-ltsc2022-amd64
    steps:
    - name: Checkout
      uses: actions/checkout@v2
    - name: Login to DockerHub
      uses: docker/login-action@v1
      with:
        username: ${{ secrets.DOCKERHUB_USERNAME }}
        password: ${{ secrets.DOCKERHUB_TOKEN }}
    - name: Docker Build
      run: |
        docker build -f ${{ matrix.file }} --build-arg BASE=${{ matrix.base }} -t ${{ matrix.tag }} .
    - name: Docker Push
      run: |
        docker push ${{ matrix.tag }}

  publish-manfiest:
    name: Publish Manifest
    runs-on: ubuntu-latest
    needs: build-publish-containers
    steps:
      - name: Checkout
        uses: actions/checkout@v2
      - name: Login to DockerHub
        uses: docker/login-action@v1
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}
      - name: Docker Manifest
        run: |
          docker manifest create phillipsj/pstools:${{ github.event.release.tag_name }} \
            --amend phillipsj/pstools:${{ github.event.release.tag_name }}-linux-amd64 \
            --amend phillipsj/pstools:${{ github.event.release.tag_name }}-windows-ltsc2019-amd64 \
            --amend phillipsj/pstools:${{ github.event.release.tag_name }}-windows-ltsc2022-amd64
      - name: Docker Annotate
        run: |
          docker manifest annotate --os windows --arch amd64 \
            --os-version "10.0.17763.1817" \
            phillipsj/pstools:${{ github.event.release.tag_name }} phillipsj/pstools:${{ github.event.release.tag_name }}-windows-ltsc2019-amd64
    
          docker manifest annotate --os windows --arch amd64 \
            --os-version "10.0.20348.169"\
            phillipsj/pstools:${{ github.event.release.tag_name }} phillipsj/pstools:${{ github.event.release.tag_name }}-windows-ltsc2022-amd64
      - name: Docker Push
        run: |
          docker manifest push phillipsj/pstools:${{ github.event.release.tag_name }}
```

## Wrapping Up

There could be a better way to do some of these, this is just how I did it. I chose not to use the [Docker build-push-action](https://github.com/docker/build-push-action/) due to the lack of Windows support offered so I favored consistency to keep it the same across all of them. Hopefully someone finds what I did here useful.

Thanks for reading,

Jamie
