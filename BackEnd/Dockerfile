FROM maven:3.9-eclipse-temurin-21-jammy AS build
COPY . .
RUN mvn clean package -DskipTests

FROM openjdk:21-jdk-slim-buster
COPY --from=build /target/demo-0.0.1-SNAPSHOT.jar demo.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "demo.jar"]
