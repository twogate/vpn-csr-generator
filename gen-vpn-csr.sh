#!/bin/bash

echo "TwoGate CSR Generator"

if [ $# -ne 2 ]; then
  echo "使用方法: bash gen-vpn-csr.sh email@example.com hostname" 1>&2
  echo "メールアドレスとホスト名の順に引数に入力します" 1>&2
  exit 1
fi

email=$1
common_name=$2

tempfile_prefix=twogate-vpn-$(date +%s)-$RANDOM
private_file=${tempfile_prefix}-private.key
csr_file=${tempfile_prefix}-csr.txt

openssl ecparam -name prime256v1 -genkey -noout -out $private_file
if [[ $? -ne 0 ]] ; then
  echo "秘密鍵作成エラー: 手動で行ってください"
  exit 1
fi

openssl req -new -sha256 -key $private_file -out $csr_file -subj "/CN=$common_name/emailAddress=$email"

if [[ $? -ne 0 ]] ; then
  echo "CSR作成エラー: 手動で行ってください"
  exit 1
fi

echo "作成しました:"
echo "  秘密鍵: $private_file"
echo "  CSR: $csr_file"

if command -v pbcopy &> /dev/null
then
  cat $csr_file | pbcopy
  echo "CSRの内容をクリップボードにコピーしました"
else
  echo "以下をコピーして管理者に渡してください:"
  cat $csr_file
fi

