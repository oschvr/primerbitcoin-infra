### Get a random AD

```
python modules/vm/ads.py "ocid1.tenancy.oc1..aaaaaaaam62jf3kca2gz5i46fagbaymp5masg7j5p36k4fpothm4gdw5yv3a" | gshuf -n1
```


```
    timestamp = regex_replace(timestamp(), "[- TZ:]", "")
    date      = formatdate("DD_MM_YYYY", timestamp())

    freeform_tags = {
        "environment" = "prod"
        "terraformed" = "please do not modify manually"
    }
```