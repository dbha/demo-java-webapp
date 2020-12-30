# Demo Java Web App

Sample java webapp demos how to build a war file to be deployed on a Tomcat server(based docker) and cf push and Tanzu Build Service.


### 1) Docker Build

    # Uses `mvn package` to produce a demo.war file and create Docker image that runs Tomcat.
      bin/build.sh
    
    # Deploy using docker run
      docker run -it -p 8080:8080 demo-java-webapp:latest
        
    # Test
      curl localhost:8080/demo/Hello
      <h1>Hello World Demo Java Web Application</h1>

### 2) cf push
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
    
### 3) TBS
    
    # prerequisite
    - Install K8s, TBS, Private Registry..
    ubuntu@ubuntu-210:~/tbs$ kubectl get po -A
    NAMESPACE        NAME                                                          READY   STATUS         RESTARTS   AGE
    build-service    secret-syncer-controller-8564df588-lpd9n                      1/1     Running        0          2d2h
    build-service    smart-warmer-controller-7d444d49c9-mqc9l                      1/1     Running        0          2d2h
    build-service    smart-warmer-image-fetcher-bgt9s                              4/4     Running        0          2d1h
    build-service    smart-warmer-image-fetcher-ssgmh                              4/4     Running        0          2d1h
    build-service    smart-warmer-image-fetcher-tcpnn                              4/4     Running        0          2d1h
    build-service    smart-warmer-image-fetcher-wn6sw                              4/4     Running        0          2d1h
    build-service    smart-warmer-image-fetcher-zdqt7                              4/4     Running        0          2d1h
    build-service    webhook-server-77cb6bb469-vbnhd                               1/1     Running        0          2d2h
    kpack            build-pod-image-fetcher-92896                                 4/4     Running        0          2d2h
    kpack            build-pod-image-fetcher-fjxdb                                 4/4     Running        0          2d2h
    kpack            build-pod-image-fetcher-g6ft5                                 4/4     Running        0          2d2h
    kpack            build-pod-image-fetcher-llklt                                 4/4     Running        0          2d2h
    kpack            build-pod-image-fetcher-s7749                                 4/4     Running        0          2d2h
    kpack            kpack-controller-575d664f4b-cn75n                             1/1     Running        0          2d2h
    kpack            kpack-webhook-55b97f8fd5-qjz5d                                1/1     Running        0          2d2h
    .....
    
    # TBS Check
    
    ubuntu@ubuntu-210:~/tbs$ kp clusterbuilder list
    NAME       READY    STACK                          IMAGE
    base       true     io.buildpacks.stacks.bionic    harbor.haas-210.pez.pivotal.io/dbha/build-service/base@sha256:82220217e93f4910dd0f529fe709129bd3f03fffecb16558fcbac310cec5a236
    default    true     io.buildpacks.stacks.bionic    harbor.haas-210.pez.pivotal.io/dbha/build-service/default@sha256:82220217e93f4910dd0f529fe709129bd3f03fffecb16558fcbac310cec5a236
    full       true     io.buildpacks.stacks.bionic    harbor.haas-210.pez.pivotal.io/dbha/build-service/full@sha256:2c3efa5fe719f628488d3108f4618d897985e7bf22ef76f1ee0d4de0c664f70d
    tiny       true     io.paketo.stacks.tiny          harbor.haas-210.pez.pivotal.io/dbha/build-service/tiny@sha256:1d801daebd1818c26d58c4b6a63b540f666aa6ea5492ebe6af1343d1f0915f65
    
    ubuntu@ubuntu-210:~/tbs$ kp clusterstack list
    NAME       READY    ID
    base       True     io.buildpacks.stacks.bionic
    default    True     io.buildpacks.stacks.bionic
    full       True     io.buildpacks.stacks.bionic
    tiny       True     io.paketo.stacks.tiny
    
    ubuntu@ubuntu-210:~/tbs$ kp clusterstore list
    NAME       READY
    default    True
    
    ubuntu@ubuntu-210:~/tbs$ kp clusterstore status default
    Status:    Ready
    
    BUILDPACKAGE ID                       VERSION    HOMEPAGE
    paketo-buildpacks/procfile            2.0.2      https://github.com/paketo-buildpacks/procfile
    tanzu-buildpacks/dotnet-core          0.0.7
    tanzu-buildpacks/go                   1.0.7
    tanzu-buildpacks/httpd                0.0.40
    tanzu-buildpacks/java                 4.0.0      https://github.com/pivotal-cf/tanzu-java
    tanzu-buildpacks/java-native-image    3.9.0      https://github.com/pivotal-cf/tanzu-java-native-image
    tanzu-buildpacks/nginx                0.0.48
    tanzu-buildpacks/nodejs               1.2.2
    tanzu-buildpacks/php                  0.0.5
     
    # Create Image
    kp image create demo-java-webapp --tag harbor.haas-210.pez.pivotal.io/dbha/demo-java-webapp --git https://github.com/dbha/demo-java-webapp.git --git-revision master
    
    ubuntu@ubuntu-210:~/tbs$ kp build logs demo-java-webapp
    ===> SETUP-CA-CERTS
    setup-ca-certs:main.go:15: create certificate...
    setup-ca-certs:main.go:21: populate certificate...
    setup-ca-certs:main.go:32: update CA certificates...
    setup-ca-certs:main.go:39: copying CA certificates...
    setup-ca-certs:main.go:45: finished setting up CA certificates
    ===> PREPARE
    Loading secret for "harbor.haas-210.pez.pivotal.io" from secret "harbor-secret" at location "/var/build-secrets/harbor-secret"
    Loading secrets for "https://github.com" from secret "git-basic-secret"
    Loading secrets for "git@github.com:dbha" from secret "git-secret"
    Successfully cloned "https://github.com/dbha/demo-java-webapp.git" @ "e283ebd978b28bad9f0430c9171b50678bf02856" in path "/workspace"
    ===> DETECT
    ======== Output: tanzu-buildpacks/go-mod-vendor@0.0.25 ========
    
    failed to parse go.mod: open /workspace/go.mod: no such file or directory
    err:  tanzu-buildpacks/go-mod-vendor@0.0.25 (1)
    7 of 33 buildpacks participating
    paketo-buildpacks/ca-certificates   1.0.1
    paketo-buildpacks/bellsoft-liberica 5.2.1
    paketo-buildpacks/maven             3.2.1
    paketo-buildpacks/executable-jar    3.1.3
    paketo-buildpacks/apache-tomcat     3.1.0
    paketo-buildpacks/dist-zip          2.2.2
    paketo-buildpacks/spring-boot       3.5.0
    ===> ANALYZE
    Previous image with name "harbor.haas-210.pez.pivotal.io/dbha/demo-java-webapp" not found
    ===> RESTORE
    ===> BUILD
    
    Paketo CA Certificates Buildpack 1.0.1
      https://github.com/paketo-buildpacks/ca-certificates
      Launch Helper: Contributing to layer
        Creating /layers/paketo-buildpacks_ca-certificates/helper/exec.d/ca-certificates-helper
        Writing profile.d/helper
    
    Paketo BellSoft Liberica Buildpack 5.2.1
      https://github.com/paketo-buildpacks/bellsoft-liberica
      Build Configuration:
        $BP_JVM_VERSION              11.*            the Java version
      Launch Configuration:
        $BPL_JVM_HEAD_ROOM           0               the headroom in memory calculation
        $BPL_JVM_LOADED_CLASS_COUNT  35% of classes  the number of loaded classes in memory calculation
        $BPL_JVM_THREAD_COUNT        250             the number of threads in memory calculation
        $JAVA_TOOL_OPTIONS                           the JVM launch flags
      BellSoft Liberica JDK 11.0.9: Contributing to layer
        Reusing cached download from buildpack
        Expanding to /layers/paketo-buildpacks_bellsoft-liberica/jdk
        Adding 128 container CA certificates to JVM truststore
        Writing env.build/JAVA_HOME.override
        Writing env.build/JDK_HOME.override
      BellSoft Liberica JRE 11.0.9: Contributing to layer
        Reusing cached download from buildpack
        Expanding to /layers/paketo-buildpacks_bellsoft-liberica/jre
        Adding 128 container CA certificates to JVM truststore
        Writing env.launch/BPI_APPLICATION_PATH.default
        Writing env.launch/BPI_JVM_CACERTS.default
        Writing env.launch/BPI_JVM_CLASS_COUNT.default
        Writing env.launch/BPI_JVM_SECURITY_PROVIDERS.default
        Writing env.launch/JAVA_HOME.default
        Writing env.launch/MALLOC_ARENA_MAX.default
      Launch Helper: Contributing to layer
        Creating /layers/paketo-buildpacks_bellsoft-liberica/helper/exec.d/active-processor-count
        Creating /layers/paketo-buildpacks_bellsoft-liberica/helper/exec.d/java-opts
        Creating /layers/paketo-buildpacks_bellsoft-liberica/helper/exec.d/link-local-dns
        Creating /layers/paketo-buildpacks_bellsoft-liberica/helper/exec.d/memory-calculator
        Creating /layers/paketo-buildpacks_bellsoft-liberica/helper/exec.d/openssl-certificate-loader
        Creating /layers/paketo-buildpacks_bellsoft-liberica/helper/exec.d/security-providers-configurer
        Creating /layers/paketo-buildpacks_bellsoft-liberica/helper/exec.d/security-providers-classpath-9
        Writing profile.d/helper
      JVMKill Agent 1.16.0: Contributing to layer
        Reusing cached download from buildpack
        Copying to /layers/paketo-buildpacks_bellsoft-liberica/jvmkill
        Writing env.launch/JAVA_TOOL_OPTIONS.append
        Writing env.launch/JAVA_TOOL_OPTIONS.delim
      Java Security Properties: Contributing to layer
        Writing env.launch/JAVA_SECURITY_PROPERTIES.default
        Writing env.launch/JAVA_TOOL_OPTIONS.append
        Writing env.launch/JAVA_TOOL_OPTIONS.delim
    
    Paketo Maven Buildpack 3.2.1
      https://github.com/paketo-buildpacks/maven
      Build Configuration:
        $BP_MAVEN_BUILD_ARGUMENTS  -Dmaven.test.skip=true package  the arguments to pass to Maven
        $BP_MAVEN_BUILT_ARTIFACT   target/*.[jw]ar                 the built application artifact explicitly.  Supersedes $BP_MAVEN_BUILT_MODULE
        $BP_MAVEN_BUILT_MODULE                                     the module to find application artifact in
      Apache Maven 3.6.3: Contributing to layer
        Reusing cached download from buildpack
        Expanding to /layers/paketo-buildpacks_maven/maven
        Creating cache directory /home/cnb/.m2
      Compiled Application: Contributing to layer
        Executing mvn -Dmaven.test.skip=true package
    [INFO] Scanning for projects...
    [INFO]
    [INFO] --------------------< com.domain:demo-java-webapp >---------------------
    [INFO] Building Demo Java Webapp 1.0-SNAPSHOT
    [INFO] --------------------------------[ war ]---------------------------------
    ....
    [INFO] Building war: /workspace/target/demo-java-webapp.war
    [INFO] ------------------------------------------------------------------------
    [INFO] BUILD SUCCESS
    [INFO] ------------------------------------------------------------------------
    [INFO] Total time:  12.020 s
    [INFO] Finished at: 2020-12-30T07:50:56Z
    [INFO] ------------------------------------------------------------------------
      Removing source code
    
    Paketo Apache Tomcat Buildpack 3.1.0
      https://github.com/paketo-buildpacks/apache-tomcat
      Build Configuration:
        $BP_TOMCAT_CONTEXT_PATH                  the application context path
        $BP_TOMCAT_EXT_CONF_SHA256               the SHA256 hash of the external Tomcat configuration archive
        $BP_TOMCAT_EXT_CONF_STRIP           0    the number of directory components to strip from the external Tomcat configuration archive
        $BP_TOMCAT_EXT_CONF_URI                  the download location of the external Tomcat configuration
        $BP_TOMCAT_EXT_CONF_VERSION              the version of the external Tomcat configuration
        $BP_TOMCAT_VERSION                  9.*  the Tomcat version
      Launch Configuration:
        $BPL_TOMCAT_ACCESS_LOGGING_ENABLED       the Tomcat access logging state
      Apache Tomcat 9.0.40: Contributing to layer
        Reusing cached download from buildpack
        Expanding to /layers/paketo-buildpacks_apache-tomcat/tomcat
        Writing env.launch/CATALINA_HOME.default
      Launch Helper: Contributing to layer
        Creating /layers/paketo-buildpacks_apache-tomcat/helper/exec.d/access-logging-support
        Writing profile.d/helper
      Apache Tomcat Support: Contributing to layer
        Copying context.xml to /layers/paketo-buildpacks_apache-tomcat/catalina-base/conf
        Copying logging.properties to /layers/paketo-buildpacks_apache-tomcat/catalina-base/conf
        Copying server.xml to /layers/paketo-buildpacks_apache-tomcat/catalina-base/conf
        Copying web.xml to /layers/paketo-buildpacks_apache-tomcat/catalina-base/conf
      Apache Tomcat Access Logging Support 3.3.0
        Reusing cached download from buildpack
        Copying to /layers/paketo-buildpacks_apache-tomcat/catalina-base/lib
      Apache Tomcat Lifecycle Support 3.3.0
        Reusing cached download from buildpack
        Copying to /layers/paketo-buildpacks_apache-tomcat/catalina-base/lib
      Apache Tomcat Logging Support 3.3.0
        Reusing cached download from buildpack
        Copying to /layers/paketo-buildpacks_apache-tomcat/catalina-base/bin
        Writing /layers/paketo-buildpacks_apache-tomcat/catalina-base/bin/setenv.sh
      Mounting application at ROOT
        Writing env.launch/CATALINA_BASE.default
      Process types:
        task:   catalina.sh run
        tomcat: catalina.sh run
        web:    catalina.sh run
    ===> EXPORT
    Adding layer 'paketo-buildpacks/ca-certificates:helper'
    Adding layer 'paketo-buildpacks/bellsoft-liberica:helper'
    Adding layer 'paketo-buildpacks/bellsoft-liberica:java-security-properties'
    Adding layer 'paketo-buildpacks/bellsoft-liberica:jre'
    Adding layer 'paketo-buildpacks/bellsoft-liberica:jvmkill'
    Adding layer 'paketo-buildpacks/apache-tomcat:catalina-base'
    Adding layer 'paketo-buildpacks/apache-tomcat:helper'
    Adding layer 'paketo-buildpacks/apache-tomcat:tomcat'
    Adding 1/1 app layer(s)
    Adding layer 'launcher'
    Adding layer 'config'
    Adding label 'io.buildpacks.lifecycle.metadata'
    Adding label 'io.buildpacks.build.metadata'
    Adding label 'io.buildpacks.project.metadata'
    *** Images (sha256:559616a873261bb5054fb1ac058d42bccb40b0c7117a94f4fc8caf0730388f01):
          harbor.haas-210.pez.pivotal.io/dbha/demo-java-webapp
          harbor.haas-210.pez.pivotal.io/dbha/demo-java-webapp:b1.20201230.075011
    Adding cache layer 'paketo-buildpacks/bellsoft-liberica:jdk'
    Adding cache layer 'paketo-buildpacks/maven:application'
    Adding cache layer 'paketo-buildpacks/maven:cache'
    Adding cache layer 'paketo-buildpacks/maven:maven'
    ===> COMPLETION
    Build successful
        
    ubuntu@ubuntu-210:~/tbs$ kp images list
    NAME                READY    LATEST IMAGE
    demo-java-webapp    True     harbor.haas-210.pez.pivotal.io/dbha/demo-java-webapp@sha256:559616a873261bb5054fb1ac058d42bccb40b0c7117a94f4fc8caf0730388f01
    
    # deploy on K8s and create service
    ubuntu@ubuntu-210:~/yaml$ kubectl apply -f demo-java-webapp.yaml
    deployment.apps/demo-java-webapp created
    
    ubuntu@ubuntu-210:~/yaml$ kubectl get po
    NAME                                       READY   STATUS      RESTARTS   AGE
    demo-java-webapp-5bcb8fb86-sgqnl           1/1     Running     0          10s
    demo-java-webapp-build-1-dzwms-build-pod   0/1     Completed   0          4m31s

    ubuntu@ubuntu-210:~/yaml$ kubectl expose deploy demo-java-webapp --name demo-java-webapp-np-svc --type=NodePort --port=8080 --target-port=8080
    service/demo-java-webapp-np-svc exposed
    
    ubuntu@ubuntu-210:~/yaml$ kubectl get svc
    NAME                      TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
    demo-java-webapp-np-svc   NodePort    100.66.114.70    <none>        8080:30851/TCP   19m
    kubernetes                ClusterIP   100.64.0.1       <none>        443/TCP          38d
    
    # Test
    ubuntu@ubuntu-210:~/yaml$ curl 10.195.93.220:30851/Hello
    <h1>Hello World Demo Java Web Application</h1>
    
    ubuntu@ubuntu-210:~$ curl 10.195.93.220:30851/index.jsp
    <html>
    <body>
    <h2>Hello World Demo Java Web Application: index.jsp</h2>
    </body>
    </html>
    
    
    