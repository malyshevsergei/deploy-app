pipeline {
    agent { 
        label 'app' 
    }

    stages {
        stage('Linter') {
            steps {
                sh '''#!/bin/bash
                source /etc/environment
                staticcheck
                '''
            }
        }
        stage('Build') {
            steps {
                sh '''#!/bin/bash
                source /etc/environment
                cd gitea
                TAGS="bindata" make build
                '''
            }
        }
        stage('Create smlink') {
            steps {
                sh '''
                #!/bin/bash

                date=$(date +"%d%m%Y")
                n=0
                
                # Increment $N as long as a directory with that name exists
                while [ -d "/opt/gitea/${date}-${n}" ] ; do
                    echo $n
                    n=$(($n+1))
                done
                
                mkdir "/opt/gitea/${date}-${n}"
                cd gitea
                cp gitea /opt/gitea/${date}-${n}
                
                unlink /opt/gitea/current || echo unlink is not needed
                
                ln -s /opt/gitea/${date}-${n}/gitea /opt/gitea/current/gitea
                
                '''
            }
        }
    }
}