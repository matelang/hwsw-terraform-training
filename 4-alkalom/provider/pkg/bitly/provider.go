package bitly

import (
	"context"
	"fmt"
	"github.com/hashicorp/terraform-plugin-sdk/v2/diag"
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
	"github.com/matelang/hwsw-bitly-provider/pkg/internal/bitly"
	"net/http"
)

func Provider() *schema.Provider {
	return &schema.Provider{
		Schema: map[string]*schema.Schema{
			"token": {
				Type:     schema.TypeString,
				Required: true,
			},
		},
		ResourcesMap: map[string]*schema.Resource{
			"bitly_bitlink": resourceBitlink(),
		},
		DataSourcesMap: map[string]*schema.Resource{
			"bitly_bitlink": dataSourceBitlink(),
		},
		ConfigureContextFunc: providerConfigure,
	}
}

func providerConfigure(ctx context.Context, d *schema.ResourceData) (interface{}, diag.Diagnostics) {
	var diags diag.Diagnostics

	client, err := bitly.NewClient("https://api-ssl.bitly.com/v4", func(client *bitly.Client) error {
		client.RequestEditors = append(client.RequestEditors, func(ctx context.Context, req *http.Request) error {
			req.Header.Add("Authorization", fmt.Sprintf("Bearer %s", d.Get("token")))
			return nil
		})
		return nil
	})
	if err != nil {
		return nil, diag.FromErr(err)
	}

	return client, diags
}
