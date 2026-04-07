# pjt_lucky Netlify 배포 메모

## 연결 방식

- GitHub 저장소와 Netlify site를 1:1로 연결합니다.
- Build command: `sh scripts/netlify-build.sh`
- Publish directory: `build/web`

## 필요 환경변수

- `FLUTTER_CHANNEL` (선택): 기본값 `stable`
- `FLUTTER_ROOT` (선택): Netlify 기본값은 `$HOME/flutter-sdk`
- `FIREBASE_API_KEY`
- `FIREBASE_APP_ID`
- `FIREBASE_MESSAGING_SENDER_ID`
- `FIREBASE_PROJECT_ID`
- `FIREBASE_AUTH_DOMAIN` (선택)
- `FIREBASE_STORAGE_BUCKET` (선택)
- `FIREBASE_MEASUREMENT_ID` (선택)
- `NETLIFY_BUILD_HOOK_URL` (선택): 수동 재배포용

## 수동 재배포

```bash
sh scripts/trigger-netlify-build.sh
```
