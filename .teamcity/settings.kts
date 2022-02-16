import jetbrains.buildServer.configs.kotlin.v2019_2.*
import jetbrains.buildServer.configs.kotlin.v2019_2.buildSteps.ScriptBuildStep
import jetbrains.buildServer.configs.kotlin.v2019_2.buildSteps.maven
import jetbrains.buildServer.configs.kotlin.v2019_2.buildSteps.script
import jetbrains.buildServer.configs.kotlin.v2019_2.triggers.vcs
import jetbrains.buildServer.configs.kotlin.v2019_2.vcs.GitVcsRoot

/*
The settings script is an entry point for defining a TeamCity
project hierarchy. The script should contain a single call to the
project() function with a Project instance or an init function as
an argument.

VcsRoots, BuildTypes, Templates, and subprojects can be
registered inside the project using the vcsRoot(), buildType(),
template(), and subProject() methods respectively.

To debug settings scripts in command-line, run the

    mvnDebug org.jetbrains.teamcity:teamcity-configs-maven-plugin:generate

command and attach your debugger to the port 8000.

To debug in IntelliJ Idea, open the 'Maven Projects' tool window (View
-> Tool Windows -> Maven Projects), find the generate task node
(Plugins -> teamcity-configs -> teamcity-configs:generate), the
'Debug' option is available in the context menu for the task.
*/

version = "2021.2"

project {
    description = "Analytics platform project for infrastructure deployment using Terraform. Ver GK1.0"

    vcsRoot(HttpsGithubComDtsStnAnalyticsPlatformGitRefsHeadsMain)
    vcsRoot(HttpsGithubComDtsStnAnalyticsPlatformRefsHeadsMain)

    buildType(BuildAndDeployAnalyticsPlatform)
    buildType(TestAutoScriptBuild)

    params {
        param("env.SAEB-SP-PASSWORD", "%vault:SAEB/data/SAEB-Terraform!/password%")
        param("env.SAEB-SP-CLIENT-ID", "%vault:SAEB/data/SAEB-Terraform!/appId%")
        param("env.SAEB-SP-TENANT-ID", "%vault:SAEB/data/SAEB-Terraform!/tenant%")
    }
}

object BuildAndDeployAnalyticsPlatform : BuildType({
    name = "Build and Deploy Analytics Platform"

    enablePersonalBuilds = false
    detectHangingBuilds = false
    publishArtifacts = PublishMode.SUCCESSFUL

    params {
        param("env.ARM_TENANT_ID", "%env.ARM_TENANT_ID%")
        password("env.AA_CLIENT_ID", "credentialsJSON:5fe54b9f-bcba-43ad-8985-c3cf616955c8", display = ParameterDisplay.HIDDEN)
        param("env.AA_CLIENT_SECRET", "26e19a43-6c6c-4f69-89cb-3fea7961e801")
        param("env.AA_PRIVATE_KEY", "MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCDVkbqofWOQuwPzRegsZwWMA18 kvPO9dMvdd/HO7EbsGzUjhHvDQU2Q+2hmHBN5RqiHx4F7kNahgSrAEshvtkCw2b0YJDF/TDdVRv5 FtbvTlSKRis25BX3pt5X9n0ytXswWO/TB72q/c4csl0e//2ZGRAQTgbk4E3nJLdSzj8+iAvPzN9S 4ijPAX3L1teMf16WhBWjRvbGcxLp2nsrcGif+ML1xGDv8bJ4HZpGofkUJw28ZUnLT2uxlAV4VFO3 qLnNr4CcA1k0gAt7ZpQ+IZaf7rs639slfXUvi4L8ygAz+qBkWJA+i6GHInwep6X8L9E4beOYzt2l tY878/Nzn5K1AgMBAAECggEAagtbr0+eKYO3fvqmPUWrNe8OtKsi2NR79DJEwWVdF3JYLTeZG19z +eDXGkcvRnXaD1T4tOkw0QKs+jV+dHzYU/baRi9CNdq9fbieoXzjhs3ETPFjKyr24cOGe5e2dx85 nEvzOH1jk5DivyD1N3aSmO83nTKjNmI2BJAMxXtqbV3PvpyEBHrZ5eWEnkHg8nqIo0aoa1vJbvzT FhpQKiFxgyoJGWKqEsYv3DSV6njSTWJMX8Yj6yHQEJJcZNfTPcTaYtlAPfWNwYl9jKXx06DLH5F/ e9C4ZNnKWQms7Oimfrxrtm6AVFTxTVHUMNcsPOEfUXzXYYSU3k6RFe03pjsigQKBgQDzXC/14Mn4 9WbPVn+TSZL1Odq731BRmzuHZ5uTSIzc50C2gMEW6tlExS+KHU4E+uVUEpkm5OogKfOXxPObnxPk 8u/3YuKGenPaSVDpkH9cegHAevOsokGXRNqHPH9/6FEDX/5BW9nGJqnrAGsR/S0qXr1qgG9nFATP 2OXmZwIe+QKBgQCKKJYRcLTnENEQ8FiHQRthuo7cKjwX96di20tRhghua6nrvJNYAQfGBtDyxWwy dSdcL5S8FGet3Lj2IdC5iieIq1u5zI7bUrvoU8IxKb22UxHPUZlgPPpE+AFIRgVmbPi6vxBfUg5Z ThJsOKx7cF1K+fxxSQDSudjskfOb+0g0nQKBgFiCwv7Ojyb5OjdW4neTXtvJ+wAxrGjB6NjKmg7r aDA/+41lLtVC/VrBzRSSq/mrtxTo3sMCpxSjrXEZtPB43yd6JET5tiHrD4/o8oDAiVH9Hf3/ufij 2u9Fn6VoH4dJ2406sKLc4UvsbAiI0mhsiKzMYGAH7nyzDzz5SkSOWnshAoGAZRTOvxHT+V7PZ3JB gyu6aeVBkomAEBUMrYI+d/X1gzxYRPZiYzfVxSfFhmm1ALHAS20wh+7x8D2WQdZ5zNXsmMyuvqCQ QJ0miBOH98pPV+8tD57m9YeHoCBHZ+Z7GvZNgOw7gVIa13IMfot0fpe2Wh3Oed/sr0B0GpmqP4w4 xu0CgYA63bU38MzYgdMdKVb9bldo6xRXPboJ1Eo+OkUKgQXk977D5apRfKenn8qmJ6IMWA0b27Cg +MM2Q46/uJCUElYkx3wcazxgt4nm/3gzJFOdgY262WDLND+4AA8f5fwrIMWS2OBr9FYubhjOGV6p AvJvqTACfDLCJC5+/NvDI1oKkg==")
        param("env.AA_SUBJECT_ACCOUNT", "362657095FDBB2670A495FBC@techacct.adobe.com")
        param("env.STATSCAN_PASSWORD", "CZd29xAtd1Goi6yc")
        param("env.AA_GLOBAL_COMPANY_ID", "canada5")
        param("env.AA_ORG_ID", "A90F2A0D55423F537F000101@AdobeOrg")
        param("env.AA_REPORT_SUITE_ID", "canadalivemain")
        param("env.STATSCAN_USERNAME", "akshat.shrivastava.1")
    }

    vcs {
        root(HttpsGithubComDtsStnAnalyticsPlatformGitRefsHeadsMain)
    }

    steps {
        script {
            name = "Terraform Init"
            workingDir = "%system.teamcity.build.checkoutDir%"
            scriptContent = """
                ls -lsa
                export ARM_CLIENT_ID=%env.SAEB-SP-CLIENT-ID%
                export ARM_CLIENT_SECRET=%env.SAEB-SP-PASSWORD%
                export ARM_SUBSCRIPTION_ID=%env.BDM_DEV_SUBSCRIPTION_ID%
                export ARM_TENANT_ID=%env.SAEB-SP-TENANT-ID%
                
                export TF_VAR_aa_client_id=%env.AA_CLIENT_ID%
                export TF_VAR_aa_client_secret=%env.AA_CLIENT_SECRET%
                export TF_VAR_aa_global_company_id=%env.AA_GLOBAL_COMPANY_ID%
                export TF_VAR_aa_org_id=%env.AA_ORG_ID%
                export TF_VAR_aa_private_key="%env.AA_PRIVATE_KEY%"
                export TF_VAR_aa_report_suite_id=%env.AA_REPORT_SUITE_ID%
                export TF_VAR_aa_subject_account=%env.AA_SUBJECT_ACCOUNT%
                export TF_VAR_statscan_username=%env.STATSCAN_USERNAME%
                export TF_VAR_statscan_password=%env.STATSCAN_PASSWORD%
                
                terraform init
                terraform plan -out test.tfplan
                terraform apply "test.tfplan"
            """.trimIndent()
            formatStderrAsError = true
            dockerImagePlatform = ScriptBuildStep.ImagePlatform.Linux
            dockerImage = "zenika/terraform-azure-cli:release-6.1_terraform-1.0.6_azcli-2.28.1"
        }
    }

    triggers {
        vcs {
            branchFilter = """
                +:<default>
                +:asolo_keyvault
            """.trimIndent()
        }
    }

    failureConditions {
        errorMessage = true
    }
})

object TestAutoScriptBuild : BuildType({
    name = "Test AutoScript Build"

    vcs {
        root(HttpsGithubComDtsStnAnalyticsPlatformRefsHeadsMain)
    }

    steps {
        maven {
            goals = "clean test"
            pomLocation = ".teamcity/pom.xml"
            runnerArgs = "-Dmaven.test.failure.ignore=true"
        }
    }

    triggers {
        vcs {
        }
    }
})

object HttpsGithubComDtsStnAnalyticsPlatformGitRefsHeadsMain : GitVcsRoot({
    name = "https://github.com/DTS-STN/Analytics-Platform.git#refs/heads/tf_test"
    url = "https://github.com/DTS-STN/Analytics-Platform.git"
    branch = "refs/heads/main"
    branchSpec = "refs/heads/*"
    authMethod = password {
        userName = "%env.GITHUB_USER%"
        password = "credentialsJSON:c6109464-b0f8-44e7-aa2d-dc335f708785"
    }
})

object HttpsGithubComDtsStnAnalyticsPlatformRefsHeadsMain : GitVcsRoot({
    name = "https://github.com/DTS-STN/Analytics-Platform#refs/heads/sl"
    url = "https://github.com/DTS-STN/Analytics-Platform"
    branch = "refs/heads/sl"
    branchSpec = "refs/heads/*"
})
