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

echo
# 버전을 올릴 프로젝트 번호를 입력하세요
read -p "버전을 올릴 프로젝트 번호를 입력하세요 (1-${#PROJECTS[@]}): " choice

if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#PROJECTS[@]}" ]; then
    project="${PROJECTS[$((choice-1))]}"
    PUBSPEC_FILE="$APPS_DIR/$project/pubspec.yaml"

    if [ -f "$PUBSPEC_FILE" ]; then
        CURRENT_VERSION=$(grep '^version:' "$PUBSPEC_FILE" | awk '{print $2}' | cut -d'+' -f1)
        echo "현재 버전: $CURRENT_VERSION"

        # 버전 분리
        IFS='.' read -r -a version_parts <<< "$CURRENT_VERSION"
        MAJOR="${version_parts[0]}"
        MINOR="${version_parts[1]}"
        PATCH="${version_parts[2]}"

        echo
        echo "버전을 올릴 방법을 선택하세요 (현재 버전 $CURRENT_VERSION)"
        echo "1) Major (release) -> $((MAJOR+1)).0.0"
        echo "2) Minor (release) -> $MAJOR.$((MINOR+1)).0"
        echo "3) Patch (hotfix)  -> $MAJOR.$MINOR.$((PATCH+1))"
        read -p "선택: " version_choice

        case "$version_choice" in
            1)
                NEW_VERSION="$((MAJOR+1)).0.0"
                BRANCH_TYPE="release"
                ;;
            2)
                NEW_VERSION="$MAJOR.$((MINOR+1)).0"
                BRANCH_TYPE="release"
                ;;
            3)
                NEW_VERSION="$MAJOR.$MINOR.$((PATCH+1))"
                BRANCH_TYPE="hotfix"
                ;;
            *)
                echo "잘못된 선택입니다."
                exit 1
                ;;
        esac

        BUILD=$(grep '^version:' "$PUBSPEC_FILE" | awk '{print $2}' | cut -d'+' -f2)
        echo
        read -p "빌드 번호를 입력하세요 (현재 빌드 번호: $BUILD): " NEW_BUILD

        echo
        sed -i '' "s/^version: .*/version: $NEW_VERSION+$NEW_BUILD/" "$PUBSPEC_FILE"
        echo "$project 버전이 $CURRENT_VERSION 에서 $NEW_VERSION+$NEW_BUILD 로 업데이트되었습니다."
        echo

        # Git 커밋 및 태그 생성
        git add "$PUBSPEC_FILE"
        git commit -m "[$project] chore: version up to $NEW_VERSION ($NEW_BUILD)"

        # 새로운 브랜치 생성
        NEW_BRANCH="${BRANCH_TYPE}-v${NEW_VERSION}"
        git checkout -b "$NEW_BRANCH"

        echo "버전이 업데이트되었고, 새로운 브랜치 '$NEW_BRANCH'가 생성되었습니다."
    else
        echo "오류: $PUBSPEC_FILE 파일을 찾을 수 없습니다."
    fi
else
    echo "잘못된 선택입니다. 1부터 ${#PROJECTS[@]} 사이의 숫자를 입력해주세요."
fi