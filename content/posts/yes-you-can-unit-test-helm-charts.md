---
title: "Yes, you can unit test Helm Charts"
date: 2022-03-28T22:13:49-04:00
tags:
- Kubernetes
- Helm
- Unit testing
- Terratest
- Open Source
- Go
- Golang
---

I have found creating [Helm](https://helm.sh/) charts a challenge as it's difficult to test as a chart gets more complex. Linting, packaging, etc. all help ease the pain and need to be used as part of a robust continuous integration, CI, process for maintaining charts. I wanted something more and started researching if it's possible to unit test a Helm chart. After a little searching, I found [Terratest](https://terratest.gruntwork.io/), by the great people over at [Gruntwork](https://gruntwork.io/), actually has a module for Helm. I have heard of Terratest when unit testing Terraform so I had experience with it already. Terratest offers two scenarios for testing charts. The first option is to test the template generation, I think of these as unit tests, and the second option is integration testing that deploys to an actual Kubernetes cluster. Let's set up a chart that is more complex than the basic example that is in the [GitHub repository](https://github.com/gruntwork-io/terratest/blob/master/test/helm_basic_example_integration_test.go) that will detect the version of Kubernetes and install a specific version of the Nginx image. We will create some template tests and then create some integration tests using [kind](https://kind.sigs.k8s.io/). I will explain what is happening in the chart as we go. Let's get started. The GitHub repository can be found [here](https://github.com/phillipsj/unit-testing-helm-charts).

## Creating our Helm Chart

The first thing is we need to create a directory for our project, a `charts` directory inside of it.

```Bash
mkdir -p helm-unit-tests/charts
```

Now we can use `helm` to create our chart with the starter template.

```Bash
cd helm-unit-tests/charts
helm create my-chart
```

Delete the `service.yaml` file in the `templates` directory and the `charts` directory inside of `my-chart`. Now we can start editing the remaining files. Let's start with creating our `values.yaml` file. We will be defining two root items, `versionOverrides` which will contain the *constraint* we want to use to determine which nginx image we want to use. Then for each constraint, we define the key and values we want to override. The last item in the file is the default version which is just the latest image.

```YAML
versionOverrides:
  - constraint: ">= 1.21 < 1.24"
    values:
      nginx:
        repository: docker.io/nginx
        tag: 1.21
  - constraint: "~ 1.20"
    values:
      nginx:
        repository: docker.io/nginx
        tag: 1.20.0
  - constraint: "~ 1.19"
    values:
      nginx:
        repository: docker.io/nginx
        tag: 1.19

nginx:
  repository: docker.io/nginx
  tag: latest
```

Next, we need to update `_helpers.tpl` within the template directory. Replace it with the following.

```YAML
{{- define "applyVersionOverrides" -}}
{{- $overrides := dict -}}
{{- range $override := .Values.versionOverrides -}}
{{- if semverCompare $override.constraint $.Capabilities.KubeVersion.Version -}}
{{- $_ := mergeOverwrite $overrides $override.values -}}
{{- end -}}
{{- end -}}
{{- $_ := mergeOverwrite .Values $overrides -}}
{{- end -}}
```

The helper above is what is going to allow us to detect the Kubernetes version of the cluster, then using semantic versioning it decides which version of nginx we want to deploy based on the constraint. Finally, it overrides the default values.

The very last piece of our chart is our `deployment.yaml` that deploys nginx. Notice how we call our helper at the top which will override the default values based on the Kubernetes version.

```YAML
{{- template "applyVersionOverrides" . -}}
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Chart.Name }}-nginx
  labels:
    component: {{ .Chart.Name }}-nginx
  namespace: {{ .Release.Namespace }}
spec:
  strategy:
    type: Recreate
  selector:
    matchLabels:
      app: {{ .Chart.Name }}-nginx
  replicas: 2
  template:
    metadata:
      labels:
        app: {{ .Chart.Name }}-nginx
    spec:
      containers:
      - name: {{ .Chart.Name }}-nginx
        image: {{ .Values.nginx.repository }}:{{ .Values.nginx.tag }}
        ports:
        - containerPort: 80
```

Now that we have that out of the way, we can get to creating our unit test.

## Creating our unit tests

Since we have a chart that makes decisions based on the Kubernetes version, it would be great to have some unit tests that exercise that logic to ensure that at least at a basic level it is working correctly. We can do that using Terratest. It is a Go-based framework so you will need to have Go installed and set up correctly. I am using Go 1.18. Let's get to the root of the project and create our directories for our tests.

```Bash
mkdir -p tests/unit
```

Inside of the `unit` directory let's create the `my_chart_template_test.go` file. Once that file is created, we can create our test. This test will define a structure for holding our different test parameters, we will then create several different scenarios, and execute each one to verify that our template is generated correctly.

```Go
package unit

import (
	"path/filepath"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/stretchr/testify/require"
	appsv1 "k8s.io/api/apps/v1"
)

const myChart = "../../charts/my-chart"

func TestTemplateRenderedDeployment(t *testing.T) {
	type args struct {
		kubeVersion   string
		namespace     string
		releaseName   string
		chartRelPath  string
		expectedImage string
	}
	tests := []struct {
		name string
		args args
	}{
		{
			name: "Kubernetes 1.23",
			args: args{
				kubeVersion:   "1.23",
				namespace:     "test-" + strings.ToLower(random.UniqueId()),
				releaseName:   "test-" + strings.ToLower(random.UniqueId()),
				chartRelPath:  myChart,
				expectedImage: "docker.io/nginx:1.21",
			},
		},
		{
			name: "Kubernetes 1.22",
			args: args{
				kubeVersion:   "1.22",
				namespace:     "test-" + strings.ToLower(random.UniqueId()),
				releaseName:   "test-" + strings.ToLower(random.UniqueId()),
				chartRelPath:  myChart,
				expectedImage: "docker.io/nginx:1.21",
			},
		},
		{
			name: "Kubernetes 1.21",
			args: args{
				kubeVersion:   "1.21",
				namespace:     "test-" + strings.ToLower(random.UniqueId()),
				releaseName:   "test-" + strings.ToLower(random.UniqueId()),
				chartRelPath:  myChart,
				expectedImage: "docker.io/nginx:1.21",
			},
		},
		{
			name: "Kubernetes 1.20",
			args: args{
				kubeVersion:   "1.20",
				namespace:     "test-" + strings.ToLower(random.UniqueId()),
				releaseName:   "test-" + strings.ToLower(random.UniqueId()),
				chartRelPath:  myChart,
				expectedImage: "docker.io/nginx:1.20.0",
			},
		},
		{
			name: "Kubernetes 1.19",
			args: args{
				kubeVersion:   "1.19",
				namespace:     "test-" + strings.ToLower(random.UniqueId()),
				releaseName:   "test-" + strings.ToLower(random.UniqueId()),
				chartRelPath:  myChart,
				expectedImage: "docker.io/nginx:1.19",
			},
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			// arrange
			chartPath, err := filepath.Abs(tt.args.chartRelPath)
			require.NoError(t, err)

			options := &helm.Options{
				KubectlOptions: k8s.NewKubectlOptions("", "", tt.args.namespace),
			}

			// act
			output := helm.RenderTemplate(t, options, chartPath, tt.args.releaseName, []string{"templates/deployment.yaml"}, "--kube-version", tt.args.kubeVersion)

			var deployment appsv1.Deployment
			helm.UnmarshalK8SYaml(t, output, &deployment)

			// assert
			require.Equal(t, tt.args.namespace, deployment.Namespace)
			deploymentSetContainers := deployment.Spec.Template.Spec.Containers
			require.Equal(t, len(deploymentSetContainers), 1)
			require.Equal(t, tt.args.expectedImage, deploymentSetContainers[0].Image)
		})
	}
}
```

Terratest provides much of the capability here, by allowing you to render a single template from a chart, you can get that YAML to then assert if the correct version was set. The only special step is we had to provide the Kubernetes version to the `RenderTemplate` function. Then it's a matter of marshaling the resulting YAML to a Go struct to perform our assertions. Let's execute our tests now.

```Bash
$ go test -v -tags helm ./tests/unit
--- PASS: TestTemplateRenderedDeployment (1.09s)
    --- PASS: TestTemplateRenderedDeployment/Kubernetes_1.23 (0.53s)
    --- PASS: TestTemplateRenderedDeployment/Kubernetes_1.22 (0.14s)
    --- PASS: TestTemplateRenderedDeployment/Kubernetes_1.21 (0.14s)
    --- PASS: TestTemplateRenderedDeployment/Kubernetes_1.20 (0.14s)
    --- PASS: TestTemplateRenderedDeployment/Kubernetes_1.19 (0.14s)
PASS
ok      github.com/user/helm-unit-tests/tests/unit        1.350s
```

## Wrapping Up

Some Helm charts can get pretty complex pretty fast and manually testing by installing it just stinks. I have already used this one chart at work and it has already saved me several times. I was able to find three different bugs in a chart from just having several test cases that exercise the helpers. Unit tests don't always capture every scenario and that is why Terratest also supports integration testing, which I will do in the following post showing how to accomplish that.

Thanks for reading,

Jamie
