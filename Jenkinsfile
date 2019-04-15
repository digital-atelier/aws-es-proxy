pipeline {
	options
    {
      buildDiscarder(logRotator(numToKeepStr: '10'))
    }
	agent none
	environment {
	SHORT_COMMIT_HASH = ''
	TEAM = 'conv'
    PROJECT = 'chatbot'
    SERVICENAME = 'es-proxy'
    ECRURL = 'https://969628048091.dkr.ecr.eu-west-1.amazonaws.com'
    ECRSHORTURL = '969628048091.dkr.ecr.eu-west-1.amazonaws.com'
    AWS_REGION = 'eu-west-1'
    TIMEOUT_IN_SECS = 180
	}
	stages {
		stage('Prepare'){
			agent {
				label 'jenkins-base-agent'
			}
			steps {
				checkout scm
			}
		}
		stage('Prepare'){
			agent {
				label 'jenkins-base-agent'
			}
			steps{
				script{
					  // checkout([$class: 'GitSCM', branches: [[name: '*/influxdb-k8s']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'da-conversation', url: 'https://github.com/digital-atelier/platform-grafana.git']]])
					  sh "node -v"
					  sh '''
            			###### Checking if ECR repo exists ######
            			if aws ecr describe-repositories --repository-name ${TEAM}-${PROJECT}-${SERVICENAME} --region ${AWS_REGION}
            			then
            			  echo ECR repo ${TEAM}-${PROJECT}-${SERVICENAME} already exists on AWS account
            			else
            			  echo ECR repo ${TEAM}-${PROJECT}-${SERVICENAME} not found, so creating...
            			  aws ecr create-repository --repository-name ${TEAM}-${PROJECT}-${SERVICENAME} --region ${AWS_REGION}
            			fi
            		  '''
        			  gitCommitHash = sh(returnStdout: true, script: 'git rev-parse HEAD').trim()
        			  SHORT_COMMIT_HASH = gitCommitHash.take(7)
        			  echo "Short Commit Hash is ${SHORT_COMMIT_HASH}"
        			  env.ECR_REPO = "${TEAM}-${PROJECT}-${SERVICENAME}"
        			  env.PROJECT_PROD_IMAGE = "$ECR_REPO:prod-$SHORT_COMMIT_HASH"
        		}
			}
		}
		stage('ProdBuild'){
			agent {
				label 'jenkins-base-agent'
			}
      		steps{
        		script {
					docker.build("$PROJECT_PROD_IMAGE",'.')
				}
			}
		}
		stage('ProdPush'){
			agent {
				label 'jenkins-base-agent'
			}
			steps{
				script{
				  sh '''set +x && $(aws ecr get-login --no-include-email --region $AWS_REGION)'''
		          docker.withRegistry("${ECRURL}",) {
		  			docker.image("$PROJECT_PROD_IMAGE").push()
				  }
				}
			}
		}
	}
}