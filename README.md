# GitHub Actions Runner Docker Image

This README provides instructions on how to build and run a Docker container that includes the GitHub Actions runner, which can be registered to a GitHub repository.

## Building the Docker Image

To build the Docker image with a specific version of the GitHub Actions runner and target architecture, use the following command:

```bash
docker build --build-arg RUNNER_VERSION=2.277.1 \
             --build-arg RUNNER_ARCH=x64 \
             --tag github_runner:latest .
```

Replace `2.277.1` with the desired version of the GitHub Actions runner and `x64` with the required architecture (e.g., `x64`, `arm64`, `arm`).

### Build Arguments

- `RUNNER_VERSION`: The version of the GitHub Actions runner you want to install.
- `RUNNER_ARCH`: The architecture of the runner. It can be `x64`, `arm64`, or `arm`.

## Running the Container

After building the image, you can run the container with the following command:

```bash
docker run --restart unless-stopped \
  -e OWNER='your-github-username' \
  -e REPOSITORY='your-repository-name' \
  -e TOKEN='your-personal-access-token' \
  -d github_runner:latest
```

Replace `your-github-username`, `your-repository-name`, and `your-personal-access-token` with your GitHub username, the repository name where you want to register the runner, and your GitHub Personal Access Token (PAT), respectively.

### Environment Variables

- `OWNER`: The owner of the GitHub repository (user or organization).
- `REPOSITORY`: The name of the repository where the runner will be registered.
- `TOKEN`: A GitHub Personal Access Token with the necessary permissions to register a self-hosted runner.

### Docker Run Options

- `--restart unless-stopped`: Ensures the container is always restarted unless it is manually stopped.
- `-e`: Sets an environment variable inside the container.
- `-d`: Runs the container in detached mode, meaning it runs in the background.

## Stopping the Container

To stop the container from restarting, you can use the following Docker command:

```bash
docker stop <container-id>
```

To find the `<container-id>`, use the `docker ps` command to list all running containers.

## Logs

To view the logs for the GitHub Actions runner, use the following command:

```bash
docker logs <container-id>
```

## Additional Notes

- Ensure that you have Docker installed and running on your system before executing these commands.
- Keep your personal access token confidential to protect your GitHub account.
- The `latest` tag is used as a convention, but you can tag the image with any name you prefer.

Refer to the official GitHub Actions documentation for more detailed information on self-hosted runners.
