# Configuration

## How does ConsoleMe determine it's configuration?

ConsoleMe is extremely configurable. For ConsoleMe to operate properly, you must provide it with a YAML configuration. ConsoleMe will attempt to locate its configuration by looking at the **CONFIG\_LOCATION** environment variable. The value of this variable should be the full path to your configuration. Example configurations are provided in the [example\_config directory](https://github.com/Netflix/consoleme/tree/master/example_config).

If you do not tell ConsoleMe where it can find a configuration, ConsoleMe will attempt to discover it. When ConsoleMe first starts, it will attempt to find its configuration based on the [Config.get\_config\_location\(\)](https://github.com/Netflix/consoleme/blob/master/consoleme/default_plugins/plugins/config/config.py#L7) function in the default\_plugins set. If you've installed a custom plugins set, it will use the logic that you've defined in your version of this function.

ConsoleMe will attempt to load a configuration in the following order:

1. `CONFIG_LOCATION` environment variable
2. `consoleme.yaml` in the current working directory
3. `~/.config/consoleme/config.yaml`
4. `/etc/consoleme/config/config.yaml`
5. `example_config/example_config_development.yaml`

If you've just cloned ConsoleMe and attempt to run it locally without making any changes, it will run with [`example_config/example_config_development.yaml`](https://github.com/Netflix/consoleme/blob/master/example_config/example_config_development.yaml)

If you plan to have multiple deployments of ConsoleMe \(Such as development, test, and production\), you'll want to have different YAML configurations for each deployment. These YAML configurations will be unique to you, and you should store them in a secure internal repository.

## Configuring ConsoleMe is complicated. Is there something that can help me generate a configuration?

We hear you, and we're pleased to offer a configuration generation script. After running through the [local Quick Start guide](../quick-start/local-development.md), run `python scripts/config/generate.py` from your ConsoleMe repository directory. This should guide you through the process of generating a basic ConsoleMe configuration.

Please provide feedback on this feature!

## Can I tell ConsoleMe to fetch its configuration from S3?

Yes!

During the initial boot of its docker image, ConsoleMe will run [a script](https://github.com/Netflix/consoleme/blob/master/scripts/retrieve_or_decode_configuration.py) that can either fetch ConsoleMe's configuration from S3, or attempt to base-64 decode the ConsoleMe's configuration.

If you wish to use this feature, upload your ConsoleMe configuration to S3 as a single file, make sure ConsoleMe is using IAM credentials with permissions to fetch that file in S3, and set the `CONSOLEME_CONFIG_S3`environment variable to the location of your configuration.

Example usage:

```text
export CONSOLEME_CONFIG_S3='s3://location/to/your/config.yaml'
```

## Can I tell ConsoleMe to store cached data in S3?

Yes!

Set the `consoleme_s3_bucket` configuration to the name of an S3 bucket. This S3 bucket should exist on the same account ConsoleMe is deployed to, and ConsoleMeInstanceProfile \(The role ConsoleMe is running as\) should have write access to the bucket.

## How can I extend configurations with one another?

If you have multiple ConsoleMe configurations for your different deployments, you'll most likely have configuration keys that are common with one another.

It is possible to "extend" one configuration YAML file with another. Examples of this can be seen in the [example\_config directory](https://github.com/Netflix/consoleme/tree/master/example_config). You'll notice that example\_config\_development.yaml extends example\_config\_header\_auth.yaml, which extends both example\_config\_base.yaml and example\_config\_secrets.yaml. If a developer runs ConsoleMe with `CONFIG_LOCATION=/path/to/example_config_development.yaml`, the resultant configuration will be a combination of all of those configurations, with keys from `example_config_development` preferred if duplicate keys exist in the extended configurations.

{% hint style="info" %}
We advise that you start with a single configuration file before extending configurations for your different environments.
{% endhint %}

## What if I extend multiple configurations with conflicting keys?

The first configuration file loaded by ConsoleMe has the highest priority, followed by the subsequent configuration files in the order that they are loaded. If you like to read code, check out the [unit tests](https://github.com/Netflix/consoleme/blob/master/tests/config/test_config.py) for this functionality.

The way this works in practice is as follows:

base.yaml:

```text
common_configuration: every_configuration_should_have_this
override_value: base_value
```

secrets.yaml:

```text
this_is_a_secret: protect_me!
```

prod.yaml:

```text
extends:
 - base.yaml
 - secrets.yaml
prod:
  value: this_is_the_prod_value
override_value: prod_value
```

test.yaml:

```text
extends:
 - base.yaml
 - secrets.yaml
test:
  value: this_is_the_test_value
override_value: test_value
```

Resulting configurations:

**`CONFIG_LOCATION=prod.yaml python consoleme/__main__.py`** :

```text
extends:
  - base.yaml
  - secrets.yaml
override_value: prod_value
common_configuration: every_configuration_should_have_this
prod:
  value: this_is_the_prod_value
this_is_a_secret: protect_me!
```

**`CONFIG_LOCATION=test.yaml python consoleme/__main__.py`** :  

```text
extends:
  - base.yaml
  - secrets.yaml
common_configuration: every_configuration_should_have_this
override_value: test_value
test:
  value: this_is_the_test_value
this_is_a_secret: protect_me!
```

## �How do I create a custom configuration?

We recommend starting with one of our example configuration files, preferably [`example_config_base.yaml`](https://github.com/Netflix/consoleme/blob/master/example_config/example_config_base.yaml), and modify it to suit your needs. You can copy it in as a part of your deployment process via S3, AWS Secrets Manager, Hashicorp Vault, or something else of your choosing.

