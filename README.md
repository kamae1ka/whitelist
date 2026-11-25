# whitelist

Список приложений/сервисов, которые на домашнем роутере (OpenWrt + Clash/mihomo)
маршрутизируются в VPN-туннель вместо прямого выхода через провайдера.

Потребитель — `/opt/clash/bin/ssclash-whitelist.sh` на роутере: он забирает
`resources.yaml` каждые 10 минут, создаёт/обновляет группы Clash, rule-providers
и правила `RULE-SET` перед `GEOIP,RU,DIRECT`.

## Формат `resources.yaml`

```yaml
app:
  myapp:                 # имя = имя группы Clash (буквы/цифры/_, без дефисов)
    domains:             # домены и "*.wildcard" -> правило по домену (SNI/Host)
      - example.com
      - "*.example.com"
    hosts:               # одиночные IP -> /32  (можно networks: с CIDR)
      - 203.0.113.10
    networks:            # CIDR, префикс не короче /20
      - 198.51.100.0/24
```

Важно: отступы ровно 2/4/6 пробелов — файл парсится простым awk на роутере.

- Новая группа создаётся как `select`: `freedom-ztv` (wg0), `freedom-smartape` (wg1),
  `DIRECT`; по умолчанию выбирается `freedom-ztv`.
- Домены автоматически резолвятся роутером в `/32` и попадают в `ipcidr.txt`
  соответствующего rule-provider (правило `no-resolve`), поэтому блокировки по IP
  тоже обходятся.
- GitHub Actions (`.github/workflows/build-routes.yml`) пересобирает `all-domains.txt`
  только из ключей `domains`; `hosts`/`networks` нужны только роутеру.

## Как добавить

1. Добавить приложение в `resources.yaml`, закоммитить и запушить в `main`.
2. На роутере применится само (cron ≤ 10 мин) либо вручную:

```sh
ssh root@192.168.1.1 '/opt/clash/bin/ssclash-whitelist.sh check'
ssh root@192.168.1.1 '/opt/clash/bin/ssclash-whitelist.sh apply'
ssh root@192.168.1.1 'logread -e ssclash-whitelist | tail -5'
```

3. Проверить на LAN-клиенте:

```sh
curl -sk -m 10 --resolve example.com:443:203.0.113.10 \
  -o /dev/null -w "%{http_code}\n" https://example.com/
```

Подробности по роутеру — в приватном репозитории `openwrt-home`,
`docs/30-clash.md`, раздел «Whitelist: как добавить приложение».
