# Increment 7 — Robustness under flaky subscribers

We onboarded a partner whose endpoint flaps — slow responses, intermittent 503s, the
occasional connection reset. Deliveries to them keep failing and our success-rate
dashboard looks terrible.

Make delivery robust under flaky subscriber endpoints. Handle this properly — I don't
want to babysit this partner's deliveries by hand every morning. Use your judgment on
the mechanism; production-quality please.
