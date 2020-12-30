#!/bin/bash -exu

mvn clean package 
mkdir -p pkg
cp target/demo-java-webapp.war pkg/demo-java-webapp.war

docker build -t demo-java-webapp .
