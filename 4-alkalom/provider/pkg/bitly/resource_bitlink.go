package bitly

import (
	"context"
	"errors"
	"fmt"
	"github.com/hashicorp/terraform-plugin-sdk/v2/diag"
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
	"github.com/matelang/hwsw-bitly-provider/pkg/internal/bitly"
	"net/http"
)

func resourceBitlink() *schema.Resource {
	return &schema.Resource{
		CreateContext: createBitlink,
		ReadContext:   readBitlink,
		UpdateContext: updateBitlink,
		DeleteContext: deleteBitlink,
		Schema: map[string]*schema.Schema{
			"id": {
				Type:     schema.TypeString,
				Computed: true,
			},
			"long_url": {
				Type:     schema.TypeString,
				Required: true,
				ForceNew: true,
			},
			"title": {
				Type:     schema.TypeString,
				Optional: true,
			},
			"created_at": {
				Type:     schema.TypeString,
				Computed: true,
			},
		},
	}
}

func createBitlink(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	client := m.(*bitly.Client)

	var diags diag.Diagnostics

	longUrl := d.Get("long_url").(string)
	title := d.Get("title").(string)

	body := &bitly.CreateFullBitlinkJSONRequestBody{
		LongUrl: longUrl,
		Title:   &title,
	}

	resp, err := client.CreateFullBitlink(ctx, *body, func(ctx context.Context, req *http.Request) error {
		return nil
	})
	if err != nil {
		return diag.FromErr(err)
	}

	createdBitlink, err := bitly.ParseCreateFullBitlinkResponse(resp)
	if err != nil {
		return diag.FromErr(err)
	}

	if createdBitlink.StatusCode() < 200 || createdBitlink.StatusCode() > 299 {
		return diag.FromErr(errors.New(fmt.Sprintf("can not create bitly link %s", createdBitlink.Status())))
	}

	id := createdBitlink.JSON200.Id
	d.SetId(*id)
	updateSchema(d, createdBitlink.JSON200)

	return diags
}

func readBitlink(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	client := m.(*bitly.Client)

	var diags diag.Diagnostics

	resp, err := client.GetBitlink(ctx, "", func(ctx context.Context, req *http.Request) error {
		req.URL.Opaque = fmt.Sprintf("%s/%s", req.URL, d.Get("id"))
		return nil
	})
	if err != nil {
		return diag.FromErr(err)
	}

	gotBitlink, err := bitly.ParseGetBitlinkResponse(resp)
	if err != nil {
		return diag.FromErr(err)
	}

	updateSchema(d, gotBitlink.JSON200)

	return diags
}

func updateBitlink(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	client := m.(*bitly.Client)

	var diags diag.Diagnostics

	longUrl := d.Get("long_url").(string)
	title := d.Get("title").(string)

	body := &bitly.UpdateBitlinkJSONRequestBody{
		HasReferences: bitly.HasReferences{},
		BitlinkUpdate: bitly.BitlinkUpdate{
			LongUrl: &longUrl,
			Title:   &title,
		},
	}

	resp, err := client.UpdateBitlink(ctx, "", *body, func(ctx context.Context, req *http.Request) error {
		req.URL.Opaque = fmt.Sprintf("%s/%s", req.URL, d.Get("id"))
		return nil
	})
	if err != nil {
		return diag.FromErr(err)
	}

	updatedBitlink, err := bitly.ParseUpdateBitlinkResponse(resp)
	if err != nil{
		return diag.FromErr(err)
	}

	id := updatedBitlink.JSON200.Id
	d.SetId(*id)
	updateSchema(d, updatedBitlink.JSON200)

	return diags
}

func deleteBitlink(ctx context.Context, d *schema.ResourceData, m interface{}) diag.Diagnostics {
	d.SetId("")

	// Valojaban kitorolni az eroforrast

	return diag.Diagnostics{}
}

func updateSchema(d *schema.ResourceData, b *bitly.BitlinkBody) {
	d.Set("id", b.Id)
	d.Set("long_url", b.LongUrl)
	d.Set("title", b.Title)
	d.Set("created_at", b.CreatedAt)
}
