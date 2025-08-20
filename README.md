# Spryker API Spec Generation Action

This action automates the process of generating and publishing Spryker Glue API specifications to an AWS S3 bucket.

## Usage

```yaml
- name: Generate and Publish Specs
  uses: spryker-sdk/gha-api-spec-upload@master
  with:
    app-type: 'b2b'
    s3-bucket: 'my-project-docs'
    aws-region: 'eu-central-1'
    aws-role-to-assume: ${{ secrets.AWS_OIDC_ROLE }}
```

## Inputs

| Input                     | Description                                                               | Required | Default                           |
| ------------------------- | ------------------------------------------------------------------------- | :------: | --------------------------------- |
| `app-type`                | The application type for naming (e.g., "b2b").                            |  `true`  |                                   |
| `deploy-file`             | Path to the `docker-sdk` deploy file.                                     |  `true`  | `deploy.ci.api.mariadb.yml`       |
| `spryker-platform-image`  | The Spryker platform Docker image tag.                                    | `false`  | `spryker/php:8.3`                 |
| `spryker-region`          | The Spryker region (e.g., EU, US).                                        | `false`  | `EU`                              |
| `s3-bucket`               | The AWS S3 bucket for uploading schemas.                                  |  `true`  |                                   |
| `s3-prefix`               | The path prefix within the S3 bucket.                                     | `false`  | `docs/api-specs`                  |
| `storefront-server-url`   | A custom server URL for the Storefront API to override the one from the generated spec. | `false`  |  |
| `backend-server-url`      | A custom server URL for the Backend API to override the one from the generated spec. | `false`  | |
| `aws-region`              | The AWS region for the S3 bucket.                                         |  `true`  |                                   |
| `aws-role-to-assume`      | The IAM Role ARN for OIDC authentication. **(Recommended)** | `false`  |                                   |
| `aws-access-key-id`       | AWS access key ID. (Use only if OIDC is unavailable).                     | `false`  |                                   |
| `aws-secret-access-key`   | AWS secret access key. (Use only if OIDC is unavailable).                 | `false`  |                                   |

## Permissions and Secrets

To use this action, you must configure the following in the calling workflow's repository:

### Permissions

The workflow needs permissions to request a token from AWS.

```yaml
permissions:
  id-token: write
  contents: read
```

### Secrets

-   If using OIDC (recommended), you must create a secret named `AWS_OIDC_ROLE` containing the full ARN of the IAM Role.
-   If using static keys, you must create secrets for `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`.
