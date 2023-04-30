# sys.argv[1]/first param should be 
# "ocid1.tenancy.oc1..aaaaaaaam62jf3kca2gz5i46fagbaymp5masg7j5p36k4fpothm4gdw5yv3a"

# Get availability domains from OCI by specifiying a compartment
import oci
import sys

if len(sys.argv) > 1:
  compartment_id = sys.argv[1]

  # Configure auth using custom profile
  config = oci.config.from_file(profile_name="oschvr")

  # Create client
  identity_client = oci.identity.IdentityClient(config)

  # Configure ads response object
  list_availability_domains_response = identity_client.list_availability_domains(compartment_id)

  # Print out ADs
  for item in range(len(list_availability_domains_response.data)):
    print(list_availability_domains_response.data[item].name)
else:
  print("Error: Enter a compartment id (OCID) to get the ADs")
  sys.exit(1)
