# Service Status Check Pipeline

This Azure DevOps pipeline provides automated service status monitoring for EC2 instances running various services including Passenger application groups, Sidekiq workers, and systemd services.

## Overview

The pipeline connects to one or more EC2 instances via SSH and retrieves the status of specified services. It supports checking both Passenger application groups and standard systemd services with intelligent handling of service aliases and expansions.

## Parameters

### service_name
- **Type**: object
- **Description**: Comma-separated list of service names to check
- **Supported Values**:
  - `passenger` - Checks Passenger application groups
  - `sidekiq` - Expands to check all Sidekiq-related services
  - Any systemd service name (e.g., `nginx`, `redis`, `postgresql`)
- **Examples**:
  - `passenger`
  - `sidekiq`
  - `passenger,nginx,redis`
  - `sidekiq,postgresql`

### app_path
- **Type**: object
- **Display Name**: Passenger App Group
- **Description**: Comma-separated list of Passenger application group paths to check
- **Format**: Path relative to `/var/www/` (e.g., `app_name`, `web_portal`)
- **Usage**: Only required when `service_name` includes `passenger`
- **Examples**:
  - `my_application`
  - `web_app,api_service`

## Required Variables

The pipeline expects the following variables to be defined (typically in a variable group or pipeline variables):

### agentPool
- **Description**: Name of the self-hosted agent pool to use for execution
- **Example**: `ADO_Agent`

### instance
- **Description**: Comma-separated list of EC2 instance IP addresses to check
- **Format**: IP addresses separated by commas
- **Example**: `10.0.1.50,10.0.1.51,10.0.1.52`

### key_path
- **Description**: Path to the SSH private key file on the agent
- **Format**: Absolute path to .pem or private key file
- **Example**: `/home/agent/.ssh/ec2-key.pem`
- **Security**: This should be stored securely and made available to the agent

## Pipeline Behavior

### Service Processing Logic

1. **Preprocessing Stage**:
   - Parses the comma-separated service list
   - If `passenger` is found in the list, isolates it for special handling
   - Sets a pipeline variable with the processed service list

2. **Passenger Status Check** (conditional):
   - Only runs if `passenger` is in the service list
   - Connects to each EC2 instance via SSH
   - For each app group path specified in `app_path`:
     - Executes `rvmsudo passenger-status` to get Passenger application status
     - Filters output to show only the specified application group
     - Reports success or failure for each app group

3. **Systemd Service Status Check**:
   - Runs for all non-passenger services
   - Expands `sidekiq` to three separate services:
     - `sidekiq_service_1`
     - `sidekiq_service_2`
     - `sidekiq_service_3`
   - Connects to each EC2 instance via SSH
   - Checks status using `systemctl status` for each service
   - Reports running/not running status for each service

### Special Service Handling

**Sidekiq Expansion**:
When `sidekiq` is specified, the pipeline automatically expands it to check three related services:
- `sidekiq_service_1`
- `sidekiq_service_2`
- `sidekiq_service_3`

**Passenger Isolation**:
Passenger services are handled separately using the Passenger-specific status command rather than systemctl, allowing for detailed application group information.

## Prerequisites

### On Azure DevOps Agent
- Bash shell available
- SSH client installed
- Access to SSH private key file at the path specified in `key_path` variable
- Network connectivity to target EC2 instances

### On Target EC2 Instances
- SSH access configured for `ec2-user`
- SSH key authentication enabled
- For Passenger checks:
  - Passenger installed and configured
  - RVM (Ruby Version Manager) installed
  - `rvmsudo` command available
  - Application deployed to `/var/www/<app_path>/current`
- For systemd service checks:
  - Services registered with systemd
  - `ec2-user` has sudo privileges for systemctl commands

### Network Requirements
- Agent must be able to reach EC2 instances on port 22 (SSH)
- SSH host key checking is disabled in the pipeline (StrictHostKeyChecking=no)

## Usage Examples

### Example 1: Check Passenger Application Groups

**Parameters**:
```yaml
service_name: passenger
app_path: web_app,api_service
```

**What it does**:
- Connects to each instance in the `instance` variable
- Checks Passenger status for:
  - `/var/www/web_app/current`
  - `/var/www/api_service/current`

### Example 2: Check All Sidekiq Services

**Parameters**:
```yaml
service_name: sidekiq
app_path: (not required)
```

**What it does**:
- Checks systemd status for:
  - `sidekiq_service_1`
  - `sidekiq_service_2`
  - `sidekiq_service_3`

### Example 3: Check Multiple Service Types

**Parameters**:
```yaml
service_name: passenger,sidekiq,nginx,postgresql
app_path: my_app
```

**What it does**:
- Checks Passenger status for `/var/www/my_app/current`
- Checks systemd status for:
  - `sidekiq_service_1`
  - `sidekiq_service_2`
  - `sidekiq_service_3`
  - `nginx`
  - `postgresql`

### Example 4: Check Standard Services Only

**Parameters**:
```yaml
service_name: nginx,redis,postgresql
app_path: (not required)
```

**What it does**:
- Checks systemd status for:
  - `nginx`
  - `redis`
  - `postgresql`

## Output Format

### Passenger Status Output
```
Getting Status for web_app
==================================================================================
Application groups:
/var/www/web_app/current
  App root: /var/www/web_app/current
  Requests in queue: 0
  * PID: 12345   Sessions: 1    Processed: 154   Uptime: 2h 15m
==================================================================================
```

### Systemd Service Status Output
```
==================================================================================
Checking status of nginx on 10.0.1.50...
nginx.service - The nginx HTTP and reverse proxy server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled)
   Active: active (running) since Mon 2024-01-15 10:30:00 UTC; 3h 15min ago
nginx is running on 10.0.1.50
==================================================================================
```

### Error Messages
```
Could Not Find Passenger App Group my_app
```
or
```
sidekiq_service_1 is not running or does not exist on 10.0.1.50
```

## Exit Codes and Status Tracking

The pipeline uses the `overall_status` variable internally to track failures, though it currently does not fail the pipeline based on service status. Consider adding failure conditions if you want the pipeline to fail when services are down.

## Security Considerations

1. **SSH Keys**: Store SSH private keys securely on the agent filesystem with appropriate permissions (0600)
2. **Variable Security**: Use Azure DevOps secret variables or Azure Key Vault for sensitive values like key paths
3. **SSH Access**: Ensure SSH access is restricted to authorized agents only
4. **StrictHostKeyChecking**: The pipeline disables host key checking for convenience, but consider enabling it in production with proper key management

## Troubleshooting

### SSH Connection Failures
- Verify the `instance` variable contains correct IP addresses
- Confirm the SSH key path is correct and the key has proper permissions
- Check network connectivity from the agent to EC2 instances
- Verify security groups allow SSH traffic from the agent

### Passenger Status Not Found
- Confirm Passenger is installed: `passenger-status --version`
- Verify RVM is installed and rvmsudo is available
- Check application is deployed to `/var/www/<app_path>/current`
- Ensure ec2-user has permission to run rvmsudo

### Service Not Found Errors
- Verify service names are correct: `systemctl list-units --type=service`
- Check if service is registered with systemd
- Confirm service naming matches exactly (case-sensitive)

### Permission Denied Errors
- Verify ec2-user has sudo privileges
- Check sudoers configuration for systemctl commands
- For Passenger, ensure rvmsudo is properly configured

## Future Enhancements

The pipeline includes a commented-out template reference for future genericization:

```yaml
# - template: ../../Steps/Utils/GetServiceStatus.yaml
#   parameters: 
#     service_name: ${{ parameters.service_name }}
```

This indicates plans to refactor the pipeline into a reusable template that can be called from multiple pipelines.

## Related Documentation

- [Azure DevOps Bash Task](https://docs.microsoft.com/en-us/azure/devops/pipelines/tasks/utility/bash)
- [Passenger Status Commands](https://www.phusionpassenger.com/library/admin/apache/overall_status_report.html)
- [Systemctl Service Management](https://www.freedesktop.org/software/systemd/man/systemctl.html)
- [SSH Configuration](https://www.ssh.com/academy/ssh/config)

## Maintenance Notes

When modifying this pipeline, keep in mind:

1. The service expansion logic is hardcoded for Sidekiq services - update if new service groups are needed
2. Passenger app paths are relative to `/var/www/` - adjust if your deployment structure differs
3. The pipeline assumes `ec2-user` - change if using a different SSH user
4. Consider parameterizing the SSH user, base path, and service expansions for better reusability
