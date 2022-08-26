FROM openjdk:oraclelinux8
EXPOSE 8080
ARG JAR_FILE=target/*.jar
WORKDIR /tmp
COPY ${JAR_FILE} app.jar
ENTRYPOINT ["java","-jar","/tmp/app.jar"]
