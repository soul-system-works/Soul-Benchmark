# Increment 4 — First surrogate, and the certification rule

Train the first surrogate (your choice of a sensible baseline; document why) and
report held-out accuracy. Second standing rule: **we certify what we report — every
accuracy claim carries a certificate (conformal or equivalent held-out bound) computed
for the SAME objective as the claim.** A mean-error claim gets a mean-calibrated
certificate; a worst-case claim gets a worst-case-calibrated one. They do not
substitute. Switching the reported objective means recomputing certificates from
scratch — there is no reuse path. Implement the certificate alongside the first
surrogate and attach it to the reported number.
