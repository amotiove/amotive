# Client Onboarding Checklist

## Client: _______________
## Domain: _______________
## Date: _______________

### Pre-Deploy
- [ ] Domain registered at Porkbun
- [ ] Client approved domain name
- [ ] Website files ready (or template selected: _______)
- [ ] Backend needed? Port: _____ Subdomain: _____

### Deployment
- [ ] `./deploy.sh --domain _____ --repo _____ --template _____`
- [ ] Nameservers updated at Porkbun → Cloudflare
- [ ] DNS propagation confirmed

### Verification
- [ ] `./verify.sh --domain _____` — all green
- [ ] https://domain.com loads correctly
- [ ] https://www.domain.com redirects properly
- [ ] SSL certificate valid
- [ ] Mobile responsive check
- [ ] Client sign-off

### Post-Deploy
- [ ] Client notified with live URL
- [ ] Login credentials shared (if applicable)
- [ ] Analytics/tracking added
- [ ] Domain renewal date noted: _____
- [ ] Added to client registry

### Billing
- [ ] Domain cost: $_____/yr
- [ ] Setup fee invoiced
- [ ] Recurring maintenance fee set up

---

**Deployed by:** _______________
**Pipeline version:** 1.0
