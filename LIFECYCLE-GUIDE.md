# Certificate lifecycle design and review guide

This guide describes a control process, not a runbook for direct CA changes. Apply it only with the certificate owner, service owner, security team, and approved change process. Product capabilities differ between Active Directory Certificate Services, third-party PKI, and Microsoft Cloud PKI for Intune.

## 1. Scope and inventory

Create an inventory boundary before collecting data:

- Identify relying services and certificate classes: user/device authentication, Wi-Fi/VPN, TLS, signing, and service identities where relevant.
- Record asset alias, certificate purpose/type, owning team, environment, issuer category, expiry, dependency, renewal method, and evidence source.
- Keep real subject names, SANs, thumbprints, serial numbers, hostnames, CA names, and internal endpoints in approved restricted systems, not a public repository.
- State which sources are covered and how completeness is assessed. A file report is only as complete and current as its input inventory.
- Give each certificate a technical owner, business/service owner, and escalation path. Resolve unowned and duplicate records before relying on the dashboard.

The supplied CSV is fictional and demonstrates a reporting shape. It is not a CA export, enrollment request, or configuration template.

## 2. Design issuance and trust

For each certificate purpose, document the relying service, identity source, enrollment path, permitted key usage/application policy, key size/algorithm policy, validity period, renewal overlap, trust chain, revocation checking, and recovery constraints. Avoid overly broad templates and requester-controlled identity fields unless explicitly required and security-reviewed.

Review template and CA permissions as distinct controls. Separate the people who administer the CA, manage templates, approve requests, operate enrollment, and revoke certificates where practical. Review delegated rights and enrollment-agent capabilities; record the intended owner for each grant. Do not place private keys or key-protection secrets in scripts, examples, or tickets.

For endpoint certificates, distinguish the trusted root/intermediate distribution from leaf enrollment and renewal. SCEP, PKCS, and Cloud PKI have different prerequisites and removal/revocation behavior. Consult the current platform-specific documentation before designing assignments or relying on automatic revocation.

## 3. Set renewal policy

Set a renewal threshold based on validity period, service criticality, enrollment lead time, change windows, and outage tolerance. A single global 30/60/90-day threshold may not fit every certificate class. Track at least:

- Expired and already failing certificates.
- Renewal due within the approved window.
- Missing owner or unknown purpose.
- Chain or revocation-check concerns.
- Renewal method and lead time not confirmed.
- Exceptions, compensating controls, approver, and expiry date.

The included script only compares expiry timestamps to the current UTC clock. It does not establish certificate trust, revocation status, identity correctness, or inventory completeness.

## 4. Renewal and deployment change plan

For a planned renewal, use a reviewable change record:

1. Verify inventory identity and ownership through an approved source.
2. Confirm requestor, template/profile, intended SAN/subject, key handling, and approval requirements.
3. Generate or request the replacement through the organization's approved process. Keep any private key in the authorized protected key store and outside this repository.
4. Validate chain, EKU/application policy, key usage, subject/SAN, lifetime, revocation reachability, and relying service compatibility in a test environment.
5. Stage the replacement, confirm service binding/deployment and client connectivity, then monitor through the agreed observation period.
6. Maintain an approved overlap and rollback plan. Do not remove the old certificate until dependency owners confirm the new path works and policy allows retirement.
7. Record timestamps, approver, test results, exceptions, and the evidence location. Store sensitive evidence in the approved system.

## 5. Revocation, compromise, and retirement

Revocation is an operational and security decision, not an expiry cleanup shortcut. Before revoking, identify affected users, devices, services, authentication flows, trust paths, and whether an active enrollment assignment may issue a replacement. Confirm the authoritative CRL/OCSP or service-side status and owner of dependent service recovery.

For suspected key compromise, follow the incident response process immediately: contain affected access, preserve evidence, determine scope, coordinate with CA and relying-service owners, revoke/replace under authorized control, distribute trust changes as needed, monitor for failures, and document recovery. Never publish compromised certificate details or incident evidence in this public repository.

CA rollover, trust-anchor removal, template retirement, and bulk revocation require a separately reviewed migration plan. Changes to a root CA or trust distribution can affect broad populations and may be irreversible in some services. This project does not automate those actions.

## 6. Least privilege and audit review

- Assign role-specific access; separate CA administration from routine certificate inventory and monitoring.
- Require documented approval for template changes, issuance exceptions, CA configuration, revocation, trust changes, and key recovery.
- Review CA and template access on a schedule and after role changes; retain evidence per organizational policy.
- Log administrative actions and request/approval outcomes. Test alerting for unexpected template changes and unusual issuance/revocation patterns.
- Store backups and recovery material under restricted access with documented restore testing; never commit them to Git.

## 7. Manual validation of the sample tool

The repository was not tested in this environment. To validate it yourself, use a disposable local copy and synthetic data only:

1. Review the PowerShell script and sample CSV before running them.
2. Run the README command in a supported PowerShell version and confirm three rows, sorted by days remaining, with Expired/RenewalDue/Current statuses relative to the date you run it.
3. Try a copied CSV with a missing column, a malformed timestamp, a blank alias, and a duplicate alias; confirm each is rejected with a useful error.
4. Confirm the report contains no certificate secret fields and that no CA, network, certificate store, Graph, or tenant connection is made.
5. If adapting it to a real sanitized export, confirm data-handling approval, column mapping, timestamp format, access controls, and retention with the data owner first.

These steps are instructions only; no tests or environment validation have been performed by this repository author.
