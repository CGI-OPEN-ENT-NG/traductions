#!/usr/bin/env groovy

pipeline {
  agent any
    stages {
      stage('Archive') {
        steps {
          checkout scm
          sh './build.sh clean archive'
        }
      }
      stage('Publish') {
        steps {
          sh './build.sh publish'
        }
      }
    }
}

