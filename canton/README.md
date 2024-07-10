# Building the Canton docker image

- Checkout the Canton sources.
- `sbt package`
- `cd enterprise/app/target/release/canton`
- Copy `Dockerfile` there.
- `docker build . -t canton:latest`
