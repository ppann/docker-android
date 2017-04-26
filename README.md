# docker-android

## Docker basics

Check local images:
`docker images`

Pull Android build image:
`docker pull ppann/docker-android`

To access 3rd party Artifactory create environment file named ".env", see example:

```
ORG_GRADLE_PROJECT_artifactory_user=user@company.example
ORG_GRADLE_PROJECT_artifactory_password=insertpasswordhere
```

Run a container based on the image we just pulled:
`docker run -it --env-file .env ppann/docker-android /bin/bash`

## Make changes to docker image

Open `/tools/docker/Dockerfile`

Make changes and save the file.

Run in bash in same directory as Dockerfile: 

`docker build .`

Result should be something like `Successfully built 81e1dfebc660`

Run `docker images`

You will now see a new untagged image:
`<none>                <none>              81e1dfebc660        16 minutes ago        2.78 GB`

Tag the new image with the correct name and versionnumber:
`docker tag 81e1dfebc660 ppann/docker-android:0.11`

And optional to mark it als "latest":
`docker tag 81e1dfebc660 ppann/docker-android:latest`

The output of `docker images` would look something like this:

```
ppann/docker-android   0.11      81e1dfebc660    17 minutes ago    2.78 GB
ppann/docker-android   latest    81e1dfebc660    17 minutes ago    2.78 GB
```

Now login to docker:
`docker login`

And upload the new image to https://hub.docker.com using:
`docker push ppann/docker-android:0.11`

If no tag is provided, Docker Engine uses the :latest tag as a default.
`docker push ppann/docker-android:latest`

----

## Copy a file 

To copy a file from a container to your computer use:
`docker cp [containter_id]:/path/to/filename.ext /local/path/filename.ext`

For example:
`docker cp 286fe67031eb:/project/platforms/android/build/outputs/apk/android-debug.apk ~/Downloads/android-debug-16.apk`







