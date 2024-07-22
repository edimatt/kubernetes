FROM python:3.12.4-alpine
RUN adduser -D fapi
USER fapi
WORKDIR /home/fapi
ENV PATH=/home/fapi/.local/bin:$PATH
RUN pip install -U pip
RUN pip install fastapi
COPY app.py app.py
EXPOSE 8080/tcp
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8080"]
