# Demo Java Web App

Sample java webapp demos how to build a war file to be deployed on a Tomcat server(based docker) and cf push

### Docker Build

    # Uses `mvn package` to produce a demo.war file and create Docker image that runs Tomcat.
      bin/build.sh
    
    # Deploy using docker run
      docker run -it -p 8080:8080 demo-java-webapp:latest
        
    # Test
      curl localhost:8080/demo/Hello
      <h1>Hello World Demo Java Web Application</h1>

### cf push
    # Use manifest.yml
    ---
    applications:
    - name: demo-java-webapp
      path: ./target/demo-java-webapp.war
      memory: 1G
      instances: 1
      buildpacks:
      - java_buildpack_offline
      env:
        JBP_CONFIG_TOMCAT: '[tomcat: {context_path: "/demo"}]'
        
    # cf push -f manifest.yml
    
    # Check
    ubuntu@ubuntu-210:~$ cf a
    Getting apps in org test-org / space test-space as tasadmin...
    OK
    name                        requested state   instances   memory   disk   urls
    demo-java-webapp            started           1/1         1G       1G     demo-java-webapp.apps.haas-210.example.com
    
    URL: demo-java-webapp.apps.haas-210.example.com/demo/Hello