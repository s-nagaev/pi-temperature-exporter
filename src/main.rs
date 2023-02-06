use actix_web::{web, App, HttpResponse, HttpServer, Responder};
use prometheus::{register_gauge, Encoder, Gauge, TextEncoder};

use lazy_static::lazy_static;

mod collectors;
use crate::collectors::temperature::get_cpu_temperature;
use crate::collectors::temperature::get_gpu_temperature;

lazy_static! {
    pub static ref CPU_TEMPERATURE: Gauge =
        register_gauge!("cpu_temperature", "CPU Temperature in Celsius").unwrap();
    pub static ref GPU_TEMPERATURE: Gauge =
        register_gauge!("gpu_temperature", "GPU Temperature in Celsius").unwrap();
}

/// Metrics endpoint handler
async fn get_metrics() -> impl Responder {
    CPU_TEMPERATURE.set(get_cpu_temperature().unwrap());
    GPU_TEMPERATURE.set(get_gpu_temperature().unwrap());

    let mut buffer = Vec::new();
    let encoder = TextEncoder::new();

    // Gather the metrics & encode them.
    let metric_families = prometheus::gather();
    encoder.encode(&metric_families, &mut buffer).unwrap();
    let output = String::from_utf8(buffer.clone()).unwrap();

    HttpResponse::Ok()
        .content_type("application/text")
        .body(output)
}

/// Health endpoint handler
async fn health() -> impl Responder {
    HttpResponse::Ok().body("")
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    HttpServer::new(|| {
        App::new()
            .route("/metrics", web::get().to(get_metrics))
            .route("/health", web::get().to(health))
    })
    .bind("0.0.0.0:9002")?
    .run()
    .await
}
