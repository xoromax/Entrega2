Pre-entrega 2: Ingesta Real-Time sobre el Entorno Base
Descripción
Esta implementación extiende la infraestructura base desarrollada en la Pre-entrega 1 mediante la incorporación de una capa de ingesta de datos en tiempo real utilizando Amazon Kinesis.

La solución implementa:

Amazon Kinesis Data Stream (KDS)
Amazon Kinesis Data Firehose (KDF)
Bucket S3 para la Bronze Layer
Cifrado mediante AWS KMS
IAM Role para Firehose
Alarmas CloudWatch para monitoreo de throughput
Flujo de validación mediante AWS CLI
Arquitectura
Producer (AWS CLI)
        │
        ▼
Kinesis Data Stream (dev-stream)
        │
        ▼
Kinesis Data Firehose (dev-firehose)
        │
        ▼
S3 Bronze Layer
(bronze-datalake-maxjaida-dev)
Recursos Implementados
Kinesis Data Stream
Nombre:

dev-stream
Configuración:

Stream Mode: PROVISIONED
Shards: 2
Encryption Type: KMS
Retention Period: 24 horas
Kinesis Data Firehose
Nombre:

dev-firehose
Configuración:

Buffer Size: 5 MB
Buffer Interval: 60 segundos
Destino:

bronze-datalake-maxjaida-dev
Prefijo dinámico:

ingesta/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/
Error Prefix:

errores/!{firehose:error-output-type}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/
Bucket Bronze Layer
Nombre:

bronze-datalake-maxjaida-dev
Uso:

Almacenamiento de datos crudos (Raw/Bronze Layer)
Persistencia near real-time mediante Firehose
CloudWatch Monitoring
Alarmas implementadas:

Escritura
WriteProvisionedThroughputExceeded
Lectura
ReadProvisionedThroughputExceeded
IAM
Role:

dev-firehose-role
Permisos:

Kinesis
kinesis:Get*
kinesis:DescribeStream
kinesis:ListShards
KMS
kms:Decrypt
kms:GenerateDataKey
kms:DescribeKey
S3
s3:PutObject
s3:GetObject
s3:ListBucket
CloudWatch
logs:PutLogEvents
logs:CreateLogStream
logs:CreateLogGroup
Outputs Terraform
audit_role_arn = arn:aws:iam::032619915567:role/audit_readonly_role

bronze_bucket_name = bronze-datalake-maxjaida-dev

data_processing_role_arn = arn:aws:iam::032619915567:role/data_processing_role

firehose_name = dev-firehose

stream_arn = arn:aws:kinesis:us-east-1:032619915567:stream/dev-stream

stream_name = dev-stream

vpc_id = vpc-0a631c0f09fdb40c5
Validación de Ingesta
Verificación del Stream
aws kinesis list-streams --region us-east-1
Resultado esperado:

dev-stream
Envío de Evento de Prueba
aws kinesis put-record --stream-name dev-stream --partition-key user-1 --data ZXZlbnRvLXBydWViYQ== --cli-binary-format raw-in-base64-out
Respuesta esperada:

{
  "ShardId": "...",
  "SequenceNumber": "..."
}
Estrategia de Partition Keys
Para evitar Hot Shards se utilizaron claves variables:

user-1
user-2
user-3
...
user-100
No se utilizó una clave constante para todos los eventos.

Ejemplo del commando utilizado:

aws kinesis put-record --stream-name dev-stream --partition-key user-1 --data ZXZlbnRvLXBydWViYQ== --cli-binary-format raw-in-base64-out
{                                                                                                                                                         
    "ShardId": "shardId-000000000001",
    "SequenceNumber": "49677354245922585484695654223164969245547236052770488338",
    "EncryptionType": "KMS"
}

Verificación de Entrega en S3
Comando utilizado:

aws s3 ls s3://bronze-datalake-maxjaida-dev --recursive
Resultado:

2026-08-13 15:47:00         33 ingesta/year=2026/month=08/day=13/dev-firehose-1-2026-08-13-19-18-05-34b5dd3d-315a-4a9b-b43a-864a7765b6b5
2026-08-13 15:51:16         94 ingesta/year=2026/month=08/day=13/dev-firehose-1-2026-08-13-19-22-33-89ecf1de-3c89-4c80-996c-b1a4839651dc
2026-08-13 15:51:43         20 ingesta/year=2026/month=08/day=13/dev-firehose-1-2026-08-13-19-50-42-5e53ad29-ad1b-493b-80ff-b3e8eaa04a82
2026-08-13 16:18:54         20 ingesta/year=2026/month=08/day=13/dev-firehose-1-2026-08-13-20-17-51-9096ce08-2e71-4ef6-af49-ec99769eae25

Esta evidencia confirma el flujo:

Producer
    ↓
Kinesis Data Stream
    ↓
Kinesis Firehose
    ↓
S3 Bronze Layer
Despliegue
Inicialización
terraform init
Validación
terraform validate
Planificación
terraform plan
Aplicación
terraform apply
Estructura del Proyecto
Entrega1/
│
├── bootstrap/
│
├── modules/
│   ├── network/
│   ├── identity/
│   └── kinesis/
│
├── environments/
│   └── dev/
│
├── README.md
├── PLAN_OUTPUT.md
└── .gitignore
