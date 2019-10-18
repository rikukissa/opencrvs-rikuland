export const HOST = process.env.HOST || '0.0.0.0'
export const PORT = process.env.PORT || 8040
export const CERT_PUBLIC_KEY_PATH =
  (process.env.CERT_PUBLIC_KEY_PATH as string) ||
  '../../../../../../.secrets/public-key.pem'
export const AUTH_URL = process.env.AUTH_URL || 'http://localhost:4040'
// Check if the token has been invalided in the auth service before it has expired
// This needs to be a string to make it easy to pass as an ENV var.
export const CHECK_INVALID_TOKEN = process.env.CHECK_INVALID_TOKEN || 'false'
export const FHIR_URL = process.env.FHIR_URL || 'http://localhost:5001/fhir'

// Mediator config
export const RUN_AS_MEDIATOR = process.env.RUN_AS_MEDIATOR || 'true'
export const OPENHIM_USER = process.env.OPENHIM_USER || 'root@openhim.org'
export const OPENHIM_PASSWORD = process.env.OPENHIM_PASSWORD || 'password'
export const OPENHIM_URL = process.env.OPENHIM_URL || 'https://localhost:8080'
export const TRUST_SELF_SIGNED = process.env.TRUST_SELF_SIGNED || 'true'

// constants that shouldn't change
export const MEDIATOR_URN = 'urn:opencrvs:dhis-mediator'