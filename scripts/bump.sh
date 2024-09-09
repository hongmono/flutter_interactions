#!/bin/bash

APPS_DIR="apps"

# Git 저장소 확인
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "오류: 현재 디렉토리가 Git 저장소가 아닙니다."
    exit 1
fi

# 프로젝트 목록 가져오기
PROJECTS=($(find $APPS_DIR -maxdepth 2 -name pubspec.yaml -exec dirname {} \; | xargs -n1 basename))

echo "프로젝트 목록:"
for i in "${!PROJECTS[@]}"; do
    echo "[$((i+1))] ${PROJECTS[$i]}"
done

# 버전을 올릴 프로젝트 번호를 입력하세요
read -p "버전을 올릴 프로젝트 번호를 입력하세요 (1-${#PROJECTS[@]}): " choice

if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#PROJECTS[@]}" ]; then
    project="${PROJECTS[$((choice-1))]}"
    PUBSPEC_FILE="$APPS_DIR/$project/pubspec.yaml"
    CHANGELOG_FILE="$APPS_DIR/$project/CHANGELOG.md"

    if [ -f "$PUBSPEC_FILE" ]; then
        VERSION=$(grep 'version:' "$PUBSPEC_FILE" | awk '{print $2}' | cut -d'+' -f1)
        BUILD=$(grep 'version:' "$PUBSPEC_FILE" | awk '{print $2}' | cut -d'+' -f2)

        echo "버전을 올릴 방법을 선택하세요:"
        echo "1) Major"
        echo "2) Minor"
        echo "3) Patch"
        read -p "선택: " version_choice

        case "$version_choice" in
            1)
                NEW_VERSION=$(echo $VERSION | awk -F. '{print $1 + 1 ".0.0"}')
                NEW_BUILD=$((BUILD + 1))
                ;;
            2)
                NEW_VERSION=$(echo $VERSION | awk -F. '{print $1 "." $2 + 1 ".0"}')
                NEW_BUILD=$((BUILD + 1))
                ;;
            3)
                NEW_VERSION=$(echo $VERSION | awk -F. '{print $1 "." $2 "." $3 + 1}')
                NEW_BUILD=$((BUILD + 1))
                ;;
            *)
                echo "잘못된 선택입니다."
                exit 1
                ;;
        esac

        sed -i '' "s/^version: .*/version: $NEW_VERSION+$NEW_BUILD/" "$PUBSPEC_FILE"
        echo "$project 버전이 $VERSION+$BUILD 에서 $NEW_VERSION+$NEW_BUILD 로 업데이트되었습니다."

        # CHANGELOG.md 업데이트
        echo "## $NEW_VERSION+$NEW_BUILD ($(date +%Y-%m-%d))" > temp_changelog.md
        echo "" >> temp_changelog.md
        git log --pretty=format:"* %s" $(git describe --tags --abbrev=0)..HEAD >> temp_changelog.md
        echo "" >> temp_changelog.md
        echo "" >> temp_changelog.md
        if [ -f "$CHANGELOG_FILE" ]; then
            cat "$CHANGELOG_FILE" >> temp_changelog.md
        fi
        mv temp_changelog.md "$CHANGELOG_FILE"

        # Git 커밋 및 태그 생성
        git add "$PUBSPEC_FILE" "$CHANGELOG_FILE"
        git commit -m "[$project] Bump version to $NEW_VERSION+$NEW_BUILD"
        git tag -a "${project}-v$NEW_VERSION" -m "[$project] Version $NEW_VERSION"

        echo "버전이 업데이트되고 커밋 및 태그가 생성되었습니다."
    else
        echo "오류: $PUBSPEC_FILE 파일을 찾을 수 없습니다."
    fi
else
    echo "잘못된 선택입니다. 1부터 ${#PROJECTS[@]} 사이의 숫자를 입력해주세요."
fi