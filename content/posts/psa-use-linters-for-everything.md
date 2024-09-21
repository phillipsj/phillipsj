---
title: "PSA: Use Linters for Everything"
date: 2024-09-20T18:22:35-04:00
tags:
- DevOps
- Cloud Native
- Opinion
- Standards
- Craftsmanship
---

This is a public service announcement. Please use linters if they’re available. Most things have linters available to check your code, YAML, Dockerfiles, Helm charts, Kubernetes manifests, Argo, etc. I think most people know about linters in the code space. Using tools like [Ruff](https://github.com/astral-sh/ruff) or [PyLint](https://pypi.org/project/pylint/) for Python, [JSLint](https://github.com/jslint-org/jslint) for JavaScript, and [Staticcheck](https://staticcheck.dev/) for Go are just a few that people may have used. Did you know there are linters built into many of the modern-day tools that people use? I'm sure you very well may, but let's review a few that I’ve found are underutilized.

## List of Linters

I covered a few code linters above, let's check out these tool-specific linters. I'm doing this in no particular order.

### Dockerfiles

There are a few linters for Dockerfiles, but my favorite is [hadolint](https://github.com/hadolint/hadolint). It works well, does [ShellCheck](https://github.com/koalaman/shellcheck) style checks on your Bash in your run commands. Here is an example Dockerfile.

```Dockerfile
FROM apline:latest

RUN apk add curl
RUN apk add weget
RUN cd /usr/app
```

This is a short Dockerfile and I didn't follow several best practices.

```Bash
$ hadolint ./Dockerfile 
./Dockerfile:1 DL3007 warning: Using latest is prone to errors if the image will ever update. Pin the version explicitly to a release tag
./Dockerfile:4 DL3059 info: Multiple consecutive `RUN` instructions. Consider consolidation.
./Dockerfile:6 DL3003 warning: Use WORKDIR to switch to a directory
./Dockerfile:6 DL3059 info: Multiple consecutive `RUN` instructions. Consider consolidation.
./Dockerfile:6 SC2164 warning: Use 'cd ... || exit' or 'cd ... || return' in case cd fails.
```

Hadolint offers a way to ignore checks that you don't want to enforce. They produce container images so you can execute the tool using `docker run`. This is a great tool to add to your [pre-commit](https://pre-commit.com/) checks and as part of your CI for pull requests.

### Helm Charts

[Helm](https://helm.sh) isn't one of my favorite technologies. YAML templating just doesn't sit well with me, however, it's popular and I do know how to use it. The `lint` command that is shipped with Helm has saved me a lot of hassle over the years and provides a good check on complex templating and control flows. Let's check out an example.

Here is a quick chart that I created.

```Bash
$ helm create lint-chart                                                                                        
Creating lint-chart
```

Now lint our newly created chart to see an example of a recommendation.

```Bash
$ helm lint ./lint-chart 
==> Linting ./lint-chart
[INFO] Chart.yaml: icon is recommended

1 chart(s) linted, 0 chart(s) failed
```

Again, this is another good tool to run as part of pre-commit or as part of our CI for pull requests. This will make sure that your chart is in the best possible condition before you start testing it more thoroughly.

### Argo Workflows

[Argo Workflows CLI](https://argo-workflows.readthedocs.io/en/latest/walk-through/argo-cli/) provides a built in `lint` command too. This is very cool as you can again add this as part of your pre-commit or CI for pull requests. Here is an example from their docs.

```YAML
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  generateName: artifact-passing-
spec:
  entrypoint: artifact-example
  templates:
  - name: artifact-example
    steps:
    - - name: generate-artifact
        template: hello-world-to-file
    - - name: consume-artifact
        template: print-message-from-file
        arguments:
          artifacts:
          - name: message
            from: "{{steps.generate-artifact.outputs.artifacts.hello-art}}"

  - name: hello-world-to-file
    container:
      image: busybox
      command: [sh, -c]
      args: ["sleep 1; echo hello world | tee /tmp/hello_world.txt"]
    outputs:
      artifacts:
      - name: hello-art
        path: /tmp/hello_world.txt

  - name: print-message-from-file
    inputs:
      artifacts:
      - name: message
        path: /tmp/message
    container:
      image: alpine:latest
      command: [sh, -c]
      args: ["cat /tmp/message"]
```

Does the template pass the linter, Let's find out.

```Bash
$ argo lint ./workflow.yaml   
✔ no linting errors found!
```

### Kubernetes Manifest

There are a few solutions in this category, I have personally been using [kube-linter](https://github.com/stackrox/kube-linter). I just grabbed an example from the Kubernetes docs to lint. Let's check out the results.

```YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
```

Now the results:

```Bash
$ kube-linter lint deployment.yaml                      
KubeLinter 0.6.8

~/deployment.yaml: (object: <no namespace>/nginx-deployment apps/v1, Kind=Deployment) object has 3 replicas but does not specify inter pod anti-affinity (check: no-anti-affinity, remediation: Specify anti-affinity in your pod specification to ensure that the orchestrator attempts to schedule replicas on different nodes. Using podAntiAffinity, specify a labelSelector that matches pods for the deployment, and set the topologyKey to kubernetes.io/hostname. Refer to https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity for details.)

~/deployment.yaml: (object: <no namespace>/nginx-deployment apps/v1, Kind=Deployment) container "nginx" does not have a read-only root file system (check: no-read-only-root-fs, remediation: Set readOnlyRootFilesystem to true in the container securityContext.)

~/deployment.yaml: (object: <no namespace>/nginx-deployment apps/v1, Kind=Deployment) container "nginx" is not set to runAsNonRoot (check: run-as-non-root, remediation: Set runAsUser to a non-zero number and runAsNonRoot to true in your pod or container securityContext. Refer to https://kubernetes.io/docs/tasks/configure-pod-container/security-context/ for details.)

~/deployment.yaml: (object: <no namespace>/nginx-deployment apps/v1, Kind=Deployment) container "nginx" has cpu request 0 (check: unset-cpu-requirements, remediation: Set CPU requests and limits for your container based on its requirements. Refer to https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#requests-and-limits for details.)

~/deployment.yaml: (object: <no namespace>/nginx-deployment apps/v1, Kind=Deployment) container "nginx" has cpu limit 0 (check: unset-cpu-requirements, remediation: Set CPU requests and limits for your container based on its requirements. Refer to https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#requests-and-limits for details.)

~/deployment.yaml: (object: <no namespace>/nginx-deployment apps/v1, Kind=Deployment) container "nginx" has memory request 0 (check: unset-memory-requirements, remediation: Set memory requests and limits for your container based on its requirements. Refer to https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#requests-and-limits for details.)

~/deployment.yaml: (object: <no namespace>/nginx-deployment apps/v1, Kind=Deployment) container "nginx" has memory limit 0 (check: unset-memory-requirements, remediation: Set memory requests and limits for your container based on its requirements. Refer to https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#requests-and-limits for details.)

Error: found 7 lint errors
```

That is a lot of information that outlines best practices. Just like many of the other tools, this one can be configured to ignore the rules that you may not be concerned about. Again, using this tool as a pre-commit hook or part of your CI for pull requests is a good idea if you feel it's important.

### YAML

Last, but definitely not least is YAML linting. Many of these tools address YAML; however, they have a more strict context than just general YAML. [yamllint](https://yamllint.readthedocs.io) is one of the available tools. Let's make a list of the three leading scorers on the Indiana Fever.

```YAML
players:
- Kesley Mitchell
- Aliyah Boston
- Caitlin Clark

```

Let's see if `yamllint` detects the issues.

```Bash
$ yamllint ./fever.yaml
./fever.yaml
  1:1       warning  missing document start "---"  (document-start)
  2:1       error    wrong indentation: expected at least 1  (indentation)
  5:1       error    too many blank lines (1 > 0)  (empty-lines)
```

It did detect the issues that are good as improper YAML often doesn't parse correctly in many tools. 

## Wrapping Up

This was just a quick tour of linters that ship with many tools you may already be using or dedicated linters for file types that you may not have considered linting before. I find it valuable to put linting as part of CICD process as it ensures that these files are going to work and to keep them meeting a standard.

I hope you found this useful, and thanks for reading,

Jamie
