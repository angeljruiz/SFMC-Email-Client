# Salesforce Marketing Cloud (SFMC) Emailer
Supports sending both transactional & triggered send (marketing) emails

## How to use
### Config
```ruby
# config/initializers/sfmc.rb

SFMC::SFMCBase.init(
  subdomain: 'mchf5m7e9wjxn-f2xxn6l5ul1x0q',
  client_id: 'client_id',
  client_secret: 'super_secret',
  default_send_classification: 'Default Send Classification - 293',
  default_subscriber_list: 'All Subscribers - 9136',
  default_data_extension: 'C4530F44-5C72-4113-8EA0-5210C9222455',
  default_bcc: ['example@example.com'] # optional
)
```

### Transactional Emails

```ruby
SFMC::Transactional::Email.send_email(
  email: 'email_name',
  to: 'example@example.com',
  params: { # Each attribute should be present in the corresponding data extension in SFMC
    First_Name: "Bob",
  }
)
```

### Triggered Send Emails

```ruby
SFMC::Triggered::Email.send_email(
  email: 'email_name',
  to: 'example@example.com',
  params: { # Each attribute should be present in the corresponding data extension in SFMC
    First_Name: "Bob",
  }
)
```

<b>Note:</b> Changes to transactional emails only take effect once its send definition is refreshed:
```ruby
SFMC::Transactional::SendDefinition.refresh 'email_name'
```

### Creating a Transactional Email Send Definition
<b>Note:</b> The first time an email is sent a send definition for it will be created with the default values. This definition take about a minute to actually become active, so try sending again after that. You can also manually create a send definition using:
```ruby
SFMC::Transactional::SendDefinition(
  definition_key: 'definition_key', 
  customer_key: 'customer_key', 
  send_classification: 'send_classification', 
  subscriber_list: 'subscriber_list', 
  data_extension: 'data_extension', 
  bcc: ['example@example.com'] # optional
)
```