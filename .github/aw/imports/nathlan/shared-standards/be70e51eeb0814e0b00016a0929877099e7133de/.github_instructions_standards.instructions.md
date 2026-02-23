---
applyTo: "**/*"
---

# Shared Standards for Cloud Infrastructure

This document contains organization-wide standards and best practices that must be followed when working with cloud infrastructure code. These standards apply across all cloud providers, projects, and provisioning methods.

## Repository Context

- These standards are defined in this repository and consumed by multiple repositories
- The rules apply to any language, tooling, or framework that interacts with cloud infrastructure
- Treat these requirements as the minimum baseline across all environments

## Core Security Principles

### 1. Private Networking (Network Isolation)

**Rule**: All deployments must use private networking if supported by the cloud provider.

**Requirements**:
- Resources should not be directly accessible from the public internet unless explicitly required
- Use private endpoints, private links, or VPC/VNet peering for inter-service communication
- Public access should be disabled by default
- When public access is necessary, implement proper access controls (IP restrictions, authentication, etc.)

**Examples**:
- Any database, object store, or cache must be deployed into private networks or private endpoints
- Public endpoints must be the exception and require documented business justification and compensating controls

### 2. Encryption at Rest and in Transit

**Rule**: All data must be encrypted both at rest and in transit.

**Requirements**:
- Enable encryption at rest for all storage resources (databases, object storage, disks, etc.)
- Use TLS/SSL for all network communication
- Use strong encryption algorithms (AES-256 for at rest, TLS 1.2+ for in transit)
- Manage encryption keys securely (use cloud provider key management services)
- Never store unencrypted sensitive data

**Examples**:
- Enable encryption at rest using the provider's native key management service
- Enforce TLS for all inbound and outbound connections, including service-to-service traffic

### 3. Logging and Monitoring

**Rule**: Enable logging and monitoring for all security-critical resources.

**Requirements**:
- Use cloud provider native monitoring and logging solutions
- Enable performance and security (audit, access, and configuration change) logs on all resources that support it
- Ship logs to central/shared monitoring solution(s) within each cloud provider tenant
- Monitor for security-relevant events and alert on anomalous activity
- Retain logs according to organizational retention policies, currently a minimum of 90 days for security-relevant logs in hot storage and 2 years in cold storage.

**Examples**:
- Enable diagnostic/audit logs and metrics for compute, storage, network, and databases, and forward them to the tenant's shared log analytics and/or SIEM
- Configure alerts for authentication failures, privilege changes, and service health events that impact performance or security

## Implementation Guidelines

When reviewing or generating code, ensure:

1. **Default to Secure**: Security features should be enabled by default, not as an afterthought
2. **Fail Securely**: If encryption or private networking cannot be enabled, the deployment should fail rather than proceed insecurely
3. **Document Exceptions**: Any exceptions to these rules must be explicitly documented. This could be comments linking to separate documentation, where the business justification, risks, and compensating controls in place are detailed. These controls must be reviewed and approved by the security team. 
4. **Use Native Features**: Our enterprise architecture prefers cloud provider native encryption and networking features over third-party solutions unless there is a compelling reason to do otherwise.
5. **Regular Reviews**: Security configurations should be reviewed regularly and updated to meet current best practices.

## Additional Considerations

- **Compliance**: These standards help meet common compliance requirements we may be subject to in future (ASD Essential Eight, NZISM, NIST, ISO 27001, SOC 2, etc.)
- **Performance**: Private networking and encryption may have minimal performance impact but significantly improve security posture
- **Cost**: Some security features (like KMS, private endpoints) have associated costs that must be factored into project budgets. Security must never be traded off for cost savings, and these costs should be planned for and justified in project proposals.
---

*These standards are living documents and may be updated as cloud security best practices evolve.*
