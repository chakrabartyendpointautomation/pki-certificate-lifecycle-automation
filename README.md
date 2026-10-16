# PKI & Certificate Lifecycle Automation

A defensive, synthetic portfolio project for tracking certificate lifecycle state, identifying renewal windows, and reviewing certificate operations across endpoint and service environments.

> This is a portfolio lab and design exercise, not a claim of production PKI administration. The documented portfolio focuses on endpoint management across Microsoft Intune, Entra ID, Jamf, and PowerShell. This project demonstrates an adjacent certificate-management workflow without presenting PKI experience as verified CV history.

## Project scope

This project demonstrates a controlled lifecycle from certificate discovery and ownership through expiry review, renewal planning, deployment verification, and retirement/revocation approval. It is separate from the portfolio’s Autopilot provisioning, endpoint inventory/reporting, and device remediation projects: its focus is certificates, trust relationships, and lifecycle governance.

Initial implementation is intentionally read-only and file-based:

- A local PowerShell inventory report reads a CSV supplied by the operator and calculates renewal status.
- A fictional sample inventory shows certificate types and lifecycle states without real names, serials, thumbprints, domains, or private-key material.
- Documentation lays out ownership, renewal, change control, revocation, recovery, and review requirements.

It does not connect to a CA, certificate store, Intune, Graph, Jamf, network endpoint, or tenant. It does not issue, renew, install, export, delete, or revoke certificates.

## Repository layout

- scripts/Get-CertificateInventory.ps1 — local CSV-only expiry and renewal-window report.
- samples/certificate-inventory.csv — synthetic planning dataset; not a CA export or issuance request.
- LIFECYCLE-GUIDE.md — design and operational review checklists.

## Lifecycle model

| Stage | Control questions |
| --- | --- |
| Discover | What systems and certificate classes are in scope? How is inventory completeness established? |
| Assign ownership | Who owns the certificate, relying service, renewal, and outage response? |
| Define purpose | Is the key usage / application policy narrow and matched to the relying service? |
| Protect issuance | Who can request, approve, issue, and administer? Are CA and template permissions reviewed? |
| Monitor | Are not-before/not-after dates, trust chain, revocation endpoints, and service dependencies tracked? |
| Renew and deploy | Is the replacement tested and staged before expiry? Are old/new overlap and rollback understood? |
| Retire or revoke | Is the action authorized, impact assessed, and dependent services checked? Is revocation status verified? |
| Audit | Are ownership, approvals, changes, exceptions, and evidence recorded with appropriate retention? |

## Quick start (local synthetic data)

Requires PowerShell 7 or Windows PowerShell 5.1. From the repository root, run:

    ./scripts/Get-CertificateInventory.ps1 -Path ./samples/certificate-inventory.csv -RenewWithinDays 60

The script reads only the specified CSV and writes a sorted report to the console. It calculates days remaining from NotAfterUtc; it does not contact a directory, CA, endpoint, or service. For operational use, feed it a sanitized inventory produced through your organization’s approved process. The input is not a PKCS#10/CA submission or a Microsoft Intune import format.

Expected report columns: AssetAlias, CertificateType, OwnerTeam, Environment, NotAfterUtc, DaysRemaining, LifecycleStatus. The sample dates are fixed synthetic values and will become expired over time; that is intentional for demonstrating report statuses.

## Safety and handling

- Never commit private keys, PFX/P12 files, passwords, access tokens, CA database backups, real certificate requests, or unredacted production exports.
- Avoid publishing real subject names, SANs, thumbprints, serial numbers, internal hostnames, domains, user/device identifiers, CA names, or revocation URLs. Use aliases and synthetic values.
- Do not use this sample as an issuance template. Do not copy private-key material into scripts, environment variables, tickets, or public CI logs.
- Apply least privilege and separation of duties to CA administration, template permissions, enrollment, approval, revocation, and key recovery. Review grants and delegated rights before any real change.
- Treat revocation, CA retirement, trust changes, template changes, and key rollover as controlled changes with dependency analysis, approval, communication, and recovery plans. Revocation and CA deletion can have broad impact; they are not automated here.
- Handle certificate inventories as sensitive operational data, even when they contain no private keys.

## Validation status

The script and sample data have not been executed or tested in this environment. No certificate authority, certificate store, Intune tenant, or production service was accessed. Follow the manual validation instructions in LIFECYCLE-GUIDE.md before adapting the workflow.

## Official references

- [Manage certificate templates in Windows Server](https://learn.microsoft.com/en-us/windows-server/identity/ad-cs/manage-certificate-templates)
- [Secure, delegate, and audit AD CS administration](https://learn.microsoft.com/en-us/windows-server/identity/ad-cs/secure-delegate-audit-certification-authority)
- [Microsoft Cloud PKI overview for Intune](https://learn.microsoft.com/en-us/intune/intune-service/protect/microsoft-cloud-pki-overview)
- [Monitor certificates issued through Intune Cloud PKI](https://learn.microsoft.com/en-us/intune/cloud-pki/monitor-certificates)
- [Remove SCEP and PKCS certificates in Intune](https://learn.microsoft.com/en-us/intune/device-configuration/certificates/remove-profiles)

These references describe distinct deployment models. Confirm current prerequisites and behavior for your CA, platform, and tenant before making changes.
