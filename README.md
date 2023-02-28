# gitlab-runner

This project will help you set up your [Gitlab runners](https://docs.gitlab.com/runner/) with docker-compose easily, Gitlab runner is an application for DevOps to run jobs of Gitlab CI/CD.

# Steps to use

1. Login to a server to deploy Gitlab runner.
2. Git clone this project to your working directory.
3. Export two variables in the server:
```
# You need admin role to get the gitlab runner registration token, Admin Area -> CI/CD -> Runners -> Register an instance runner -> Registration token
export GITLAB_RUNNER_TOKEN=<your-gitlab-runner-registration-token>
export GITLAB_URL=<your-gitlab-url>
```
4. Run `docker-compose up -d`.
5. Check CI/CD Runners in Admin Area of your Gitlab website, there should be a runner online.

# Additional usage

## Automatic tag the commit

Take maven project as an example.

**_NOTE:_** Make sure a shared gitlab runner or specific runner is available under your project, you can confirm it in <your-project> -> Settings -> CI/CD -> Runners(Expand), you can see a blue cycle if it's available.

1. Firstly, we need configure .gitlab-ci.yml to trigger Gitlab CI/CD, here is my `.gitlab-ci.yml` for automatic tagging the commit.
```
stages:
  - deploy

image: maven-git:latest

tag:
  before_script:
    - VERSION=$(mvn -q -Dexec.executable=echo -Dexec.args='${project.version}' --non-recursive exec:exec)
    - git fetch
    - project_url=$(echo $CI_PROJECT_URL | sed 's/http:\/\///')
    - git remote set-url origin http://oauth2:$TAG_CREATION_TOKEN@$project_url
  script:
    - echo "Automatic build and tag the commit"
    - tag=v${VERSION}
    - git tag $tag
    - git push origin $tag
  stage: deploy
  only:
    refs:
      - release
  except:
    - merge_requests
```

2. Then a CI/CD variable $TAG_CREATION_TOKEN is required, it could be initiated in User Setting -> Access Tokens -> Personal Access Tokens, recommend using a specific account such as ci-bot to restrict the access.
3. Configure TAG_CREATION_TOKEN as a global CI/CD variable or project CI/CD variable.
- Global CI/CD variable: Admin Area -> Settings -> CD/CD -> Variables(Expand)
- Project CI/CD variable: <your-project> -> Settings -> CD/CD -> Variables(Expand)
4. Next, a docker image should be prepared to run the script, we need maven, git and java in the docker container, so I customized my own docker image in [./images/maven](./images/maven).
- `build.sh` is used to create the docker image.
- `load.sh` is used to save .tar file, copy to gitlab-runner and load it, I have to do so because there's no docker register in my test environment.
5. At last, you can change your version in pom.xml, commit to the target branch and see the result. 