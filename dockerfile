# Use the official .NET SDK image as the build environment
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build-env

# Set the working directory inside the container
WORKDIR /workspace

# Copy the local NuGet packages to the same level as the application

# Copy the entire application to the working directory
COPY . .

# Restore the dependencies using the local package source   # --packages ./packages
RUN dotnet restore ap1/ 

# Build the application
RUN dotnet publish -c Release -o out ap1/

# Use the official .NET runtime image as the runtime environment
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS runtime

# Set the working directory inside the container
WORKDIR /workspace

# Create a non-root user and group
RUN addgroup --system appgroup && adduser --system --ingroup appgroup appuser

# Change ownership of the workspace to the non-root user
RUN chown -R appuser:appgroup /workspace

# Switch to the non-root user
USER appuser

# Copy the built application from the build environment
COPY --from=build-env /workspace/out .

# Copy the local NuGet packages to the runtime container
COPY --from=build-env /workspace/packages ./packages

# Expose any required ports (optional)
# EXPOSE 80

# Define the entry point for the application
ENTRYPOINT ["dotnet", "ap1.dll"]

# to make it dynamic we need to change 
# 1) app1 directory to environmental variable or set it default for everybody or remove directory at all and copy code directly to workspace
# 2) packages directory should probably be volume connecting container to directory in server
# 3) every app1 etc


#application name ap1

#config file 
#<?xml version="1.0" encoding="utf-8"?>
#<configuration>
#  <packageSources>
#    <add key="LocalPackages" value="/workspace/packages" />
#  </packageSources>
#</configuration>
