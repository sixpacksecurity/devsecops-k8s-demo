FROM openjdk:oraclelinux8
EXPOSE 8080
ARG JAR_FILE=target/*.jar
WORKDIR /app
COPY ${JAR_FILE} app.jar
ENTRYPOINT ["java","-jar","/app.jar"]
