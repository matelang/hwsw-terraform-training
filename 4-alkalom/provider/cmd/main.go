package main

import (
"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
"github.com/hashicorp/terraform-plugin-sdk/v2/plugin"
	"github.com/matelang/hwsw-bitly-provider/pkg/bitly"
)

func main() {
	plugin.Serve(&plugin.ServeOpts{
		ProviderFunc: func() *schema.Provider {
			return bitly.Provider()
		},
	})
}
