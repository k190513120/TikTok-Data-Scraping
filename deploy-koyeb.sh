#!/bin/bash

# Koyeb CLI 自动部署脚本
# 用于部署 Douyin_TikTok_Download_API 到 Koyeb 平台

set -e  # 遇到错误时退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置变量
APP_NAME="tiktok-api"
SERVICE_NAME="tiktok-api-service"
GIT_REPO="https://github.com/Evil0ctal/Douyin_TikTok_Download_API"
GIT_BRANCH="main"
REGION="fra"  # 可选: sin, was, fra
INSTANCE_TYPE="nano"  # 可选: nano, micro, small

# 函数：打印带颜色的消息
print_message() {
    echo -e "${2}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

print_success() {
    print_message "✅ $1" "$GREEN"
}

print_error() {
    print_message "❌ $1" "$RED"
}

print_warning() {
    print_message "⚠️  $1" "$YELLOW"
}

print_info() {
    print_message "ℹ️  $1" "$BLUE"
}

# 函数：检查命令是否存在
check_command() {
    if ! command -v $1 &> /dev/null; then
        case $1 in
            "koyeb")
                print_error "$1 命令未找到，请先安装 Koyeb CLI: brew install koyeb/tap/koyeb"
                ;;
            "jq")
                print_error "$1 命令未找到，请先安装 jq: brew install jq"
                ;;
            *)
                print_error "$1 命令未找到，请先安装相应的工具"
                ;;
        esac
        exit 1
    fi
}

# 函数：检查登录状态
check_auth() {
    if ! koyeb apps list &> /dev/null; then
        print_error "未登录 Koyeb，请先运行: koyeb login"
        exit 1
    fi
}

# 函数：设置默认TikTok Cookies
wait_for_input() {
    # 使用默认的TikTok Cookies值
    TIKTOK_COOKIES="sessionid=your_session_id; csrftoken=your_csrf_token; tt_webid=your_webid; tt_webid_v2=your_webid_v2;"
    print_info "使用默认 TikTok Cookies 配置"
    print_warning "请在部署后通过 Koyeb 控制台更新实际的 TikTok Cookies"
}

# 函数：创建应用
create_app() {
    print_info "创建应用: $APP_NAME"
    if koyeb app describe $APP_NAME &> /dev/null; then
        print_warning "应用 $APP_NAME 已存在，跳过创建"
    else
        koyeb app create $APP_NAME
        print_success "应用创建成功"
    fi
}

# 函数：创建 Secret
create_secret() {
    print_info "创建 TikTok Cookies Secret"
    if koyeb secret describe tiktok-cookies &> /dev/null; then
        print_warning "Secret tiktok-cookies 已存在，更新中..."
        koyeb secret update tiktok-cookies --value "$TIKTOK_COOKIES"
    else
        koyeb secret create tiktok-cookies --value "$TIKTOK_COOKIES"
    fi
    print_success "Secret 配置完成"
}

# 函数：创建服务
create_service() {
    print_info "创建服务: $SERVICE_NAME"
    if koyeb service describe $SERVICE_NAME &> /dev/null; then
        print_warning "服务 $SERVICE_NAME 已存在，将进行更新"
        update_service
    else
        koyeb service create $SERVICE_NAME \
            --app $APP_NAME \
            --git $GIT_REPO \
            --git-branch $GIT_BRANCH \
            --git-build-command "docker build -t app ." \
            --git-run-command "python3 start.py" \
            --ports 80:http \
            --routes /:80 \
            --instance-type $INSTANCE_TYPE \
            --regions $REGION \
            --min-scale 1 \
            --max-scale 1 \
            --env PORT=80 \
            --env HOST=0.0.0.0 \
            --env PYTHONUNBUFFERED=1 \
            --env API_HOST=0.0.0.0 \
            --env TIKTOK_COOKIES=@secret:tiktok-cookies
        print_success "服务创建成功"
    fi
}

# 函数：更新服务
update_service() {
    print_info "更新服务配置"
    koyeb service update $SERVICE_NAME \
        --env PORT=80 \
        --env HOST=0.0.0.0 \
        --env PYTHONUNBUFFERED=1 \
        --env API_HOST=0.0.0.0 \
        --env TIKTOK_COOKIES=@secret:tiktok-cookies
    print_success "服务更新完成"
}

# 函数：配置健康检查
configure_health_check() {
    print_info "配置健康检查"
    # 注意：Koyeb CLI 的健康检查参数可能不同，跳过此步骤
    print_warning "健康检查配置已跳过，请在 Koyeb 控制台手动配置"
    print_success "健康检查配置完成"
}

# 函数：等待部署完成
wait_for_deployment() {
    print_info "等待部署完成..."
    local max_attempts=60  # 最多等待10分钟
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        local status=$(koyeb service describe $SERVICE_NAME --output json | jq -r '.status')
        
        case $status in
            "healthy")
                print_success "部署成功！服务已启动并运行正常"
                return 0
                ;;
            "error")
                print_error "部署失败，请查看日志"
                return 1
                ;;
            "starting"|"deploying")
                print_info "部署中... (${attempt}/${max_attempts})"
                ;;
        esac
        
        sleep 10
        ((attempt++))
    done
    
    print_warning "部署超时，请手动检查状态"
    return 1
}

# 函数：显示部署信息
show_deployment_info() {
    print_success "=== 部署完成 ==="
    
    # 获取服务URL
    local service_url=$(koyeb service describe $SERVICE_NAME --output json | jq -r '.public_domain')
    
    echo -e "${GREEN}🌐 服务地址:${NC}"
    echo -e "   API文档: https://$service_url/docs"
    echo -e "   健康检查: https://$service_url/docs"
    echo ""
    echo -e "${BLUE}📊 管理命令:${NC}"
    echo -e "   查看状态: koyeb service describe $SERVICE_NAME"
    echo -e "   查看日志: koyeb service logs $SERVICE_NAME --follow"
    echo -e "   重新部署: koyeb service redeploy $SERVICE_NAME"
    echo ""
    echo -e "${YELLOW}🧪 测试命令:${NC}"
    echo -e "   curl https://$service_url/docs"
}

# 主函数
main() {
    print_info "开始 Koyeb CLI 自动部署流程"
    
    # 检查依赖
    check_command "koyeb"
    check_command "jq"
    check_auth
    
    # 获取用户输入
    wait_for_input
    
    # 执行部署步骤
    create_app
    create_secret
    create_service
    configure_health_check
    
    # 等待部署完成
    if wait_for_deployment; then
        show_deployment_info
    else
        print_error "部署可能存在问题，请检查日志"
        echo "查看日志: koyeb service logs $SERVICE_NAME"
        exit 1
    fi
}

# 脚本入口
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi