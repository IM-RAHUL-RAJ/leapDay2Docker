# ---- Build stage (JDK 21) ----
FROM maven:3.9.6-eclipse-temurin-21 AS build
WORKDIR /app

# Pre-fetch deps for better caching
COPY pom.xml .
RUN mvn -q -e -DskipTests dependency:go-offline

# Copy sources and build
COPY src ./src
RUN mvn clean package -DskipTests

# ---- Runtime stage (JRE/JDK 21) ----
FROM eclipse-temurin:21-jre
# If you prefer Debian slim: FROM openjdk:21-jdk-slim
WORKDIR /app

# Adjust the JAR name if your build produces something else
COPY --from=build /app/target/*.jar /app/app.jar

EXPOSE 8081
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
