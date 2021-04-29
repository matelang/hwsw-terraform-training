package bitly

import (
	"context"
	"fmt"
	"github.com/hashicorp/terraform-plugin-sdk/v2/diag"
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
	"github.com/matelang/hwsw-bitly-provider/pkg/internal/bitly"
	"net/http"
)

func dataSourceBitlink() *schema.Resource {
	return &schema.Resource{
		ReadContext: dataSourceBitlinkRead,
		Schema: map[string]*schema.Schema{
			"id": {
				Type:     schema.TypeString,
				Required: true,
			},
			"link": {
				Type:     schema.TypeString,
				Computed: true,
			},
			"long_url": {
				Type:     schema.TypeString,
				Computed: true,
			},
			"title": {
				Type:     schema.TypeString,
				Computed: true,
			},
			"created_at": {
				Type:     schema.TypeString,
				Computed: true,
			},
		},
	}
}

func dataSourceBitlinkRead(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	client := m.(*bitly.Client)

	resp, err := client.GetBitlink(ctx, "", func(ctx context.Context, req *http.Request) error {
		req.URL.Opaque = fmt.Sprintf("%s/%s", req.URL, d.Get("id"))
		return nil
	})
	if err != nil {
		return diag.FromErr(err)
	}

	bl, err := bitly.ParseGetBitlinkResponse(resp)
	if err != nil {
		return diag.FromErr(err)
	}

	d.SetId(*bl.JSON200.Id)
	d.Set("id", *bl.JSON200.Id)

	d.Set("link", bl.JSON200.Link)
	d.Set("long_url", bl.JSON200.LongUrl)
	d.Set("title", bl.JSON200.Title)
	d.Set("created_at", bl.JSON200.CreatedAt)

	return diag.Diagnostics{}
}
