FROM nexadata/base

RUN set -ex \
    && pip install uv

COPY pyproject.toml ${LAMBDA_TASK_ROOT}
RUN set -ex \
    && uv lock --directory ${LAMBDA_TASK_ROOT} \
    && uv export -q --directory ${LAMBDA_TASK_ROOT} --frozen --no-dev --no-editable -o ${LAMBDA_TASK_ROOT}/requirements.txt \
    && uv pip install -q --no-installer-metadata --no-compile-bytecode -r ${LAMBDA_TASK_ROOT}/requirements.txt --target ${LAMBDA_TASK_ROOT}

COPY app ${LAMBDA_TASK_ROOT}/app
COPY nexadata ${LAMBDA_TASK_ROOT}/nexadata

CMD [ "app.lambda_function.lambda_handler" ]
