// --- FRONTEND --- //
module "frontend" {
  source = "../../modules/s3-static-site"

  # S3 
  frontend_bucket_name = "cloudpipe-website-s3"

/*
  # CloudFront
  dist_aliases    = [""]
  certificate_arn = ""
*/

}
