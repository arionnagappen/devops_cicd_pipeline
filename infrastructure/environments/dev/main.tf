// --- FRONTEND --- //
module "frontend" {
  source = "../../modules/s3-static-site"

  # S3 
  frontend_bucket_name = "cloudpipe-website-s3"

  # CloudFront
  certificate_arn = "arn:aws:acm:us-east-1:536697234818:certificate/6399a90c-3132-4488-9e3a-c4bddd09dcc2"
  active_environment = "/green"
}