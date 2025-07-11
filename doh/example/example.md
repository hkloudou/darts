# DoH 客户端使用示例

这里展示了如何使用 DNS over HTTPS (DoH) 客户端库进行各种 DNS 查询操作。

## 基本使用

```dart
import 'package:doh/doh.dart';

void main() async {
  // 创建 DoH 客户端
  final doh = DoH();
  
  try {
    // 查询 A 记录
    final results = await doh.lookup('google.com', DohRequestType.A);
    print('IP 地址: ${results.map((r) => r.data).join(', ')}');
  } finally {
    // 清理资源
    doh.dispose();
  }
}
```

## 不同类型的记录查询

```dart
// A 记录 (IPv4 地址)
final aRecords = await doh.lookup('example.com', DohRequestType.A);

// AAAA 记录 (IPv6 地址)  
final aaaaRecords = await doh.lookup('example.com', DohRequestType.AAAA);

// MX 记录 (邮件服务器)
final mxRecords = await doh.lookup('example.com', DohRequestType.MX);

// TXT 记录 (文本记录)
final txtRecords = await doh.lookup('example.com', DohRequestType.TXT);

// NS 记录 (名称服务器)
final nsRecords = await doh.lookup('example.com', DohRequestType.NS);
```

## 缓存控制

```dart
// 启用缓存查询 (默认)
final results1 = await doh.lookup('example.com', DohRequestType.A, cache: true);

// 禁用缓存查询
final results2 = await doh.lookup('example.com', DohRequestType.A, cache: false);

// 清除特定缓存
doh.clearCache('example.com', DohRequestType.A);

// 查看缓存状态
print('缓存条目数: ${doh.cacheEntryCount}');
```

## 自定义提供商

```dart
// 使用 Cloudflare 提供商
final cloudflareClient = DoH(providers: [DoHProvider.cloudflare1]);

// 使用推荐的提供商
final recommendedClient = DoH(providers: DoHProvider.recommendedProviders);

// 使用中国优化的提供商
final chinaClient = DoH(providers: DoHProvider.chinaOptimizedProviders);
```

## 错误处理

```dart
try {
  final results = await doh.lookup('example.com', DohRequestType.A);
  print('查询成功: ${results.length} 条记录');
} on DnsResolutionException catch (e) {
  print('DNS 解析失败: ${e.message}');
} on NetworkException catch (e) {
  print('网络错误: ${e.message}');
} on ArgumentError catch (e) {
  print('参数错误: ${e.message}');
}
```

## 超时和重试

```dart
final results = await doh.lookup(
  'example.com',
  DohRequestType.A,
  timeout: Duration(seconds: 10),  // 10 秒超时
  attempts: 3,                     // 重试 3 次
);
```

## 并发查询

```dart
final domains = ['google.com', 'github.com', 'stackoverflow.com'];

// 并发查询多个域名
final futures = domains.map((domain) => 
    doh.lookup(domain, DohRequestType.A));

final results = await Future.wait(futures);

for (int i = 0; i < domains.length; i++) {
  print('${domains[i]}: ${results[i].map((r) => r.data).join(', ')}');
}
```

## 记录详细信息

```dart
final results = await doh.lookup('example.com', DohRequestType.A);

for (final record in results) {
  print('域名: ${record.name}');
  print('类型: ${record.typeName} (${record.type})');
  print('数据: ${record.data}');
  print('TTL: ${record.remainingTtl} 秒');
  print('提供商: ${record.provider}');
  print('有效: ${record.isValid}');
  print('过期: ${record.isExpired}');
}
```

## 支持的记录类型

- `DohRequestType.A` - IPv4 地址记录
- `DohRequestType.AAAA` - IPv6 地址记录
- `DohRequestType.CNAME` - 别名记录
- `DohRequestType.MX` - 邮件交换记录
- `DohRequestType.NS` - 名称服务器记录
- `DohRequestType.TXT` - 文本记录
- `DohRequestType.SRV` - 服务记录
- `DohRequestType.SOA` - 授权起始记录
- `DohRequestType.PTR` - 指针记录
- 以及更多 DNSSEC 和其他记录类型...

## 可用的提供商

- `DoHProvider.google1` / `DoHProvider.google2` - Google Public DNS
- `DoHProvider.cloudflare1` / `DoHProvider.cloudflare2` - Cloudflare DNS
- `DoHProvider.quad9` - Quad9 DNS
- `DoHProvider.alidns` / `DoHProvider.alidns2` - 阿里公共 DNS
- `DoHProvider.opendns1` / `DoHProvider.opendns2` - OpenDNS
- `DoHProvider.adguard` - AdGuard DNS
- `DoHProvider.dnssb` - DNS.SB

查看完整示例代码：[doh_example.dart](./doh_example.dart)