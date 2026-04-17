package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestExamplesEksCloudwatchOtlp(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../examples/eks-cloudwatch-otlp",
		Vars: map[string]interface{}{
			"eks_cluster_id": "e2e-tests",
			"aws_region":     "us-west-2",
		},
		PlanOnly: true,
	}

	terraform.InitAndPlan(t, terraformOptions)
}
